// Home screen: projects in progress and the Finished shelf, or an empty state

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.themeColor) private var themeColor
    @Environment(\.modelContext) private var modelContext
    @Environment(ProStore.self) private var proStore
    let launchFinished: Bool

    @Query(filter: #Predicate<Project> { project in
        project.isFinished == false
    }, sort: \Project.createdAt)
    private var projectsInProgress: [Project]

    @Query(filter: #Predicate<Project> { project in
        project.isFinished == true
    }, sort: \Project.finishedAt, order: .reverse)
    private var finishedProjects: [Project]

    @State private var showingNewProject = false
    @State private var showingOnboarding = false
    @State private var showingSettings = false
    @State private var showingLimit = false
    @State private var showingPaywall = false
    @State private var wantsPaywall = false
    @State private var projectToEdit: Project?
    @State private var projectToDelete: Project?
    @State private var path = NavigationPath()
    @AppStorage("hasFinishedOnboarding") private var hasFinishedOnboarding = false
    // Testing only: -showOnboarding shows it once per launch
    static var forcedOnboardingShown = false

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if projectsInProgress.isEmpty && finishedProjects.isEmpty {
                    emptyState
                } else {
                    projectList
                }
            }
            .background(Color.warmBackground)
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gearshape.fill") {
                        showingSettings = true
                        Haptics.light()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New project", systemImage: "plus") {
                        startNewProject()
                    }
                    .fontWeight(.bold)
                    .buttonStyle(.glassProminent)
                }
            }
            .sheet(isPresented: $showingNewProject) {
                NewProjectSheet()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            // "See Itomi Pro" closes this sheet first, then the paywall opens
            .sheet(isPresented: $showingLimit, onDismiss: {
                if wantsPaywall {
                    wantsPaywall = false
                    showingPaywall = true
                }
            }) {
                ProjectLimitSheet(projectsGoing: projectsInProgress.count) {
                    wantsPaywall = true
                    showingLimit = false
                }
            }
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView(openedFrom: "Home")
            }
            .navigationDestination(for: Project.self) { project in
                ProjectDetailView(project: project)
            }
            .navigationDestination(for: Part.self) { part in
                if let project = part.project {
                    CounterView(project: project, part: part)
                }
            }
            // Welcome screens, only the first time the app opens
            .fullScreenCover(isPresented: $showingOnboarding) {
                NavigationStack {
                    WelcomeView { project in
                        finishOnboarding(with: project)
                    }
                }
            }
            .onAppear {
                #if DEBUG
                SampleData.addIfAsked(into: modelContext, existing: projectsInProgress + finishedProjects)
                #endif
                checkOnboarding()
            }
            .onChange(of: launchFinished) {
                checkOnboarding()
            }
        }
    }

    // Free plan: 2 projects going at a time (finished ones don't count)
    func startNewProject() {
        Haptics.light()
        if proStore.isPro || projectsInProgress.count < 2 {
            showingNewProject = true
        } else {
            Analytics.projectLimitReached()
            showingLimit = true
        }
    }

    // Show onboarding once the launch animation is done, unless there are already projects
    func checkOnboarding() {
        if launchFinished == false {
            return
        }
        #if DEBUG
        // Testing: launch with -showOnboarding to see it again without deleting any projects
        if CommandLine.arguments.contains("-showOnboarding") && ProjectsView.forcedOnboardingShown == false {
            ProjectsView.forcedOnboardingShown = true
            showingOnboarding = true
            return
        }
        #endif
        if hasFinishedOnboarding {
            return
        }
        if projectsInProgress.isEmpty && finishedProjects.isEmpty {
            showingOnboarding = true
        } else {
            hasFinishedOnboarding = true
        }
    }

    // Close onboarding and open the new project's counter
    func finishOnboarding(with project: Project) {
        hasFinishedOnboarding = true
        showingOnboarding = false
        path.append(project)
        if let onlyPart = project.sortedParts.first {
            path.append(onlyPart)
        }
    }

    var projectList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if projectsInProgress.isEmpty == false {
                    SectionTitle(text: "In progress")
                        .padding(.top, 8)
                    inProgressCard
                }

                if finishedProjects.isEmpty == false {
                    HStack(spacing: 8) {
                        SectionTitle(text: "Finished")
                        CountBadge(count: finishedProjects.count)
                    }
                    .padding(.top, 20)
                    finishedGrid
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .sheet(item: $projectToEdit) { project in
            NewProjectSheet(projectToEdit: project)
        }
        // A centered alert, so it never looks like it's pointing at the wrong project
        .alert(deleteTitle, isPresented: showingDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Project", role: .destructive) {
                deleteProject()
            }
        } message: {
            Text("Its parts and counts go too. This can't be undone.")
        }
    }

    // Hold a project to edit, move or delete it
    @ViewBuilder
    func projectMenu(for project: Project) -> some View {
        Button("Edit", systemImage: "pencil") {
            projectToEdit = project
        }
        if project.isFinished {
            Button("Make another", systemImage: "arrow.trianglehead.2.clockwise") {
                makeAnother(of: project)
            }
            Button("Back to In progress", systemImage: "arrow.uturn.backward") {
                project.isFinished = false
                project.finishedAt = nil
                Haptics.light()
                saveChanges()
            }
        }
        Button("Delete", systemImage: "trash", role: .destructive) {
            projectToDelete = project
        }
    }

    // Pro: start a fresh copy of a finished project and open it (free: show Itomi Pro)
    func makeAnother(of project: Project) {
        if proStore.isPro == false {
            Haptics.light()
            showingPaywall = true
            return
        }
        let copy = project.makeFreshCopy(named: nameForCopy(of: project), in: modelContext)
        saveChanges()
        Analytics.projectCreated(copy, from: "Make another")
        Haptics.success()
        path.append(copy)
    }

    // "Bunny 2", or "Bunny 3" if there's already a Bunny 2 (copying "Bunny 2" also starts from "Bunny")
    func nameForCopy(of project: Project) -> String {
        var baseName = project.name
        let words = project.name.split(separator: " ")
        if words.count > 1, let lastWord = words.last, Int(lastWord) != nil {
            baseName = words.dropLast().joined(separator: " ")
        }

        var takenNames: [String] = []
        for other in projectsInProgress + finishedProjects {
            takenNames.append(other.name)
        }

        var number = 2
        while takenNames.contains("\(baseName) \(number)") {
            number += 1
        }
        return "\(baseName) \(number)"
    }

    // e.g. "Delete Bunny?"
    var deleteTitle: String {
        let name = projectToDelete?.name ?? "project"
        return "Delete \(name)?"
    }

    // Shows the delete question whenever a project is picked for deleting
    var showingDeleteConfirm: Binding<Bool> {
        Binding(
            get: { projectToDelete != nil },
            set: { isShowing in
                if isShowing == false {
                    projectToDelete = nil
                }
            }
        )
    }

    // Delete the picked project and its parts
    func deleteProject() {
        guard let project = projectToDelete else {
            return
        }
        LockScreenCounter.projectEnded(project)
        modelContext.delete(project)
        projectToDelete = nil
        Haptics.medium()
        saveChanges()
    }

    func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Couldn't save projects: \(error)")
        }
    }

    // White card with one row per project in progress
    var inProgressCard: some View {
        VStack(spacing: 0) {
            ForEach(projectsInProgress) { project in
                NavigationLink(value: project) {
                    HStack {
                        ProjectRow(project: project)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
                .contextMenu {
                    projectMenu(for: project)
                }

                // Line between rows, starting after the photo
                if project != projectsInProgress.last {
                    Divider()
                        .padding(.leading, 86)
                }
            }
        }
        .padding(.vertical, 6)
        .background(.background, in: RoundedRectangle(cornerRadius: 26))
    }

    // Finished projects, three across, wrapping onto new lines
    var finishedGrid: some View {
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

        return LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
            ForEach(finishedProjects) { project in
                NavigationLink(value: project) {
                    VStack(alignment: .leading, spacing: 8) {
                        FinishedTile(project: project)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(project.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            Text(finishedDateText(for: project))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 2)
                    }
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
                .contextMenu {
                    projectMenu(for: project)
                }
            }
        }
    }

    // e.g. "Oct 18", the day the project was finished
    func finishedDateText(for project: Project) -> String {
        guard let date = project.finishedAt else {
            return "Finished"
        }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }

    var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text("Nothing on the hook")
            } icon: {
                LoopMark(size: 72, color: themeColor.opacity(0.35))
            }
        } description: {
            Text("Start a project and count your first row.")
        } actions: {
            Button("New project") {
                showingNewProject = true
                Haptics.light()
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }
}

#Preview {
    ProjectsView(launchFinished: true)
        .environment(ProStore())
        .modelContainer(for: Project.self, inMemory: true)
}

// A finished project's square photo that fills its spot in the grid
struct FinishedTile: View {
    @Environment(\.themeColor) private var themeColor
    let project: Project

    var body: some View {
        Color.cream
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let data = project.photo, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    LoopMark(size: 56, color: themeColor)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .accessibilityHidden(true)
    }
}

// Small cream pill with a number, e.g. the 4 next to "Finished"
struct CountBadge: View {
    @Environment(\.themeColor) private var themeColor
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(themeColor)
            .padding(.horizontal, 9)
            .padding(.vertical, 2)
            .background(Color.cream, in: Capsule())
    }
}
