import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var draft = DreamEntry()
    @State private var editingItem: DreamEntry? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 44))
                            .foregroundStyle(Theme.textSecondary)
                        Text("Nothing logged yet")
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else {
                    List {
                        ForEach(store.items) { item in
                            Button {
                                editingItem = item
                                draft = item
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.text)
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.textPrimary)
                                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(Theme.captionFont)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                            .listRowBackground(Theme.card)
                            .accessibilityIdentifier("row_\(item.id.uuidString)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Dreamledger")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            draft = DreamEntry()
                            editingItem = nil
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                addSheet
            }
            .sheet(item: $editingItem) { _ in
                addSheet
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    private var addSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Text", text: $draft.text, axis: .vertical)
                        .accessibilityIdentifier("field_text")
                    TextField("Mood", text: $draft.mood, axis: .vertical)
                        .accessibilityIdentifier("field_mood")
                }
            }
            .navigationTitle(editingItem == nil ? "Add" : "Edit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAdd = false
                        editingItem = nil
                    }
                    .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let editing = editingItem {
                            let updated = DreamEntry(id: editing.id, createdAt: editing.createdAt, text: draft.text, mood: draft.mood)
                            store.update(updated)
                        } else {
                            _ = store.add(draft, isPro: purchases.isPro)
                        }
                        showingAdd = false
                        editingItem = nil
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
        .environmentObject(PurchaseManager())
}
