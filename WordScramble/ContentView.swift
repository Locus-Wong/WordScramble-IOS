//
//  ContentView.swift
//  WordScramble
//
//  Created by Locus Wong on 2025-07-09.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var currentScore = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack{
            Text("Current Score: \(currentScore)")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
            List {
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section{
                    ForEach(usedWords, id:\.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            } .navigationTitle(rootWord)
                .toolbar{
                    Button("New Word", action: startGame)
                        .font(.system(size: 25, weight: .semibold))
                        .frame(minWidth: 44, minHeight: 44) // Ensures good tap target
                }
                .onSubmit {
                    addNewWord()
                }
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError){} message: { Text(
                    errorMessage
                )}
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(
                title: "Word not possible",
                message: "You can't spell that word from '\(rootWord)' !")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isTooSimple(word: answer) else {
            wordError(title: "Word is too simple", message: "Try something longer!")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
            currentScore += answer.count
        }
        
        newWord = ""
    }
    
    // UTF-8 is the standard encoding for most text files
    // It's efficient for English text and compatible with ASCII
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(
                contentsOf: startWordsURL,
                encoding: .utf8
            ){
                
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    // NSRange and UITextChecker are part of the Foundation/UIKit frameworks, which are based on Objective-C
    // Objective-C strings (NSString) internally use UTF-16 encoding
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(
            in: word,
            range: range,
            startingAt: 0,
            wrap: false,
            language: "en"
        )
        
        return misspelledRange.location == NSNotFound
    }
    
    func isTooSimple(word: String) -> Bool {
        word.count >= 3
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
