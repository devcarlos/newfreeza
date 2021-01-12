import Foundation

class FavoritesViewModel {
    var hasError = false
    var errorMessage: String?
    var entries = [EntryViewModel]()

    private var afterTag: String?

    init() {
    }

    func loadEntries(withCompletion completionHandler: @escaping () -> ()) {
        self.afterTag = ""

        //mock data for testing favorites
        let favorite1 = Favorite(entry: EntryModel.entry1)
        let favorite2 = Favorite(entry: EntryModel.entry2)
        let favorite3 = Favorite(entry: EntryModel.entry3)
        Persistence.shared.createOrUpdate(object: favorite1)
        Persistence.shared.createOrUpdate(object: favorite2)
        Persistence.shared.createOrUpdate(object: favorite3)

        let favorites = Persistence.shared.fetch(with: nil, sortDescriptors: [])

        let newEntries = favorites.map { favorite -> EntryViewModel in

            let entryModel = EntryModel(object: favorite)
            let entryViewModel = EntryViewModel(withModel: entryModel)

            return entryViewModel
        }

        self.entries.append(contentsOf: newEntries)

        self.hasError = false
        self.errorMessage = nil

        DispatchQueue.main.async {
            completionHandler()
        }
    }
}
