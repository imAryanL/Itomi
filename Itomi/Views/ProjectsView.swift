// Home screen: projects in progress and the Finished shelf, or an empty state

import SwiftUI
import SwiftData

struct ProjectsView: View {
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
    @State private var path = NavigationPath()
    @AppStorage("hasFinishedOnboarding") private var hasFinishedOnboarding = false

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
                    Button("Settings", systemImage: "gearshape") {
                        showingSettings = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New project", systemImage: "plus") {
                        showingNewProject = true
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .sheet(isPresented: $showingNewProject) {
                NewProjectSheet()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
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
                checkOnboarding()
            }
            .onChange(of: launchFinished) {
                checkOnboarding()
            }
        }
    }

    // Show onboarding once the launch animation is done, unless there are already projects
    func checkOnboarding() {
        if launchFinished == false || hasFinishedOnboarding {
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
        List {
            if projectsInProgress.isEmpty == false {
                Section("In progress") {
                    ForEach(projectsInProgress) { project in
                        NavigationLink(value: project) {
                            ProjectRow(project: project)
                        }
                    }
                }
            }

            if finishedProjects.isEmpty == false {
                Section {
                    finishedShelf
                } header: {
                    HStack {
                        Text("Finished")
                        Spacer()
                        Text("\(finishedProjects.count)")
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
        }
        .scrollContentBackground(.hidden)
    }

    // Side-scrolling row of finished projects
    var finishedShelf: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(finishedProjects) { project in
                    NavigationLink(value: project) {
                        VStack(alignment: .leading, spacing: 6) {
                            ProjectThumbnail(project: project, size: 110)
                            Text(project.name)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        .frame(width: 110)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        // Keep names clear of the row's rounded bottom corner
        .padding(.bottom, 20)
    }

    var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text("Nothing on the hook")
            } icon: {
                LoopMark(size: 72, color: .accent.opacity(0.35))
            }
        } description: {
            Text("Start a project and count your first row.")
        } actions: {
            Button("New project") {
                showingNewProject = true
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
        }
    }
}

#Preview {
    ProjectsView(launchFinished: true)
        .modelContainer(for: Project.self, inMemory: true)
}
