import Foundation

class FavoritesViewModel {
    var hasError = false
    var errorMessage: String?
    var entries:[EntryViewModel] = []

    private var afterTag: String?

    init() {
    }

    func loadEntries(withCompletion completionHandler: @escaping () -> ()) {
        self.afterTag = ""

        let favorites = Persistence.shared.fetch(with: nil, sortDescriptors: [])

        let newEntries = favorites.map { favorite -> EntryViewModel in

            let entryModel = EntryModel(object: favorite)
            let entryViewModel = EntryViewModel(withModel: entryModel)

            return entryViewModel
        }

        self.entries = Array(newEntries)

        self.hasError = false
        self.errorMessage = nil

        DispatchQueue.main.async {
            completionHandler()
        }
    }
}
