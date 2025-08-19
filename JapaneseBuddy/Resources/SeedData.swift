import Foundation

/// Static seed data for initial decks.
enum SeedData {
    private static let hira = "あ い う え お か き く け こ さ し す せ そ た ち つ て と な に ぬ ね の は ひ ふ へ ほ ま み む め も や ゆ よ ら り る れ ろ わ を ん".split(separator: " ").map(String.init)
    private static let kata = "ア イ ウ エ オ カ キ ク ケ コ サ シ ス セ ソ タ チ ツ テ ト ナ ニ ヌ ネ ノ ハ ヒ フ ヘ ホ マ ミ ム メ モ ヤ ユ ヨ ラ リ ル レ ロ ワ ヲ ン".split(separator: " ").map(String.init)
    private static let romaji = "a i u e o ka ki ku ke ko sa shi su se so ta chi tsu te to na ni nu ne no ha hi fu he ho ma mi mu me mo ya yu yo ra ri ru re ro wa wo n".split(separator: " ").map(String.init)

    static func makeCards() -> [Card] {
        var cards: [Card] = []
        for (s, r) in zip(hira, romaji) {
            cards.append(Card(type: .hiragana, front: s, back: r, reading: r))
        }
        for (s, r) in zip(kata, romaji) {
            cards.append(Card(type: .katakana, front: s, back: r, reading: r))
        }
        return cards
    }
}

