import Foundation

struct Verb: Codable {
    let verb: String
    let tenses: [String: [String]] // Tense name as key, conjugations as value
}

func loadVerbs() -> [Verb]? {
    guard let url = Bundle.main.url(forResource: "verbs", withExtension: "json") else {
        print("Error: Verbs JSON file not found in the bundle.")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        let verbs = try JSONDecoder().decode([Verb].self, from: data)
        return verbs.sorted { $0.verb < $1.verb } // Sort verbs alphabetically
    } catch {
        print("Error loading or decoding verbs: \(error)")
        return nil
    }
}


