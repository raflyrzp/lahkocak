import std.stdio;
import std.string;
import std.file;
import std.algorithm;
import std.path;
import std.regex;

struct ArticleData {
    string content;
    int wordCount;
    int[string] wordFreq;
    int[string] conjunctionFreq;
    int[char] alphaNumericFreq;
}

void main()
{
    string[] file;
    string[] content;
    int[] wordCount;
    int[string][] wordFreq;
    int[string][] conjunctionFreq;
    int[char][] alphaNumericFreq;

    string[][] splittedWord;

    string folderPath = "text_db";
    ArticleData[string] textDB;

    foreach (entry; dirEntries(folderPath, SpanMode.shallow))
    {
        if (entry.isFile)
        {
            string fileName = baseName(entry.name);
            string fileContent = readText(entry);
            file ~= fileName;
            content ~= fileContent;

            string[] wordsInFile = splitWords(fileContent);
            splittedWord ~= wordsInFile;

            int wordCountInFile = cast(int)wordsInFile.length;
            wordCount ~= wordCountInFile;

            int[string] fileWordFreq = wordOccurrence(wordsInFile);
            wordFreq ~= fileWordFreq;

            int[string] fileConjunctionFreq = countConjunctions(wordsInFile);
            conjunctionFreq ~= fileConjunctionFreq;

            int[char] fileAlphaNumericFreq = alphaNumericOccurrence(fileContent);
            alphaNumericFreq ~= fileAlphaNumericFreq;

            textDB[fileName] = ArticleData(
                content: fileContent,
                wordCount: wordCountInFile,
                wordFreq: fileWordFreq,
                conjunctionFreq: fileConjunctionFreq,
                alphaNumericFreq: fileAlphaNumericFreq
            );
        }
    }

    // Output hasil untuk setiap file
    foreach (fileName, data; textDB)
    {
        writeln("File: ", fileName);
        writeln("Content: ", data.content);
        writeln("Word Count: ", data.wordCount);
        writeln("Word Frequency: ", data.wordFreq);
        writeln("Conjunction Frequency: ", data.conjunctionFreq);
        writeln("Alpha Numeric Frequency: ", data.alphaNumericFreq);
    }
}

string cleanText(string text){
    auto re = regex(r"\[\d+\]"); 
    auto reNonAlpha = regex(r"[^a-zA-Z\s]");

    string cleanedText = replaceAll(text, re, "");
    cleanedText = replaceAll(cleanedText, reNonAlpha, "");

    return cleanedText;
}

string[] splitWords(string text){
    string cleaned = cleanText(text);
    string[] splittedText = cleaned.toLower.split();

    return splittedText;
}

int[string] wordOccurrence(string[] words){
    int[string] wordFreq;
    foreach (word; words) wordFreq[word]++;

    return wordFreq;
}

int[char] alphaNumericOccurrence(string text){
    int[char] alphaNumericFreq;
    foreach (char ch; text) {
        if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9')) {
            alphaNumericFreq[ch]++;
        }
    }

    return alphaNumericFreq;
}

int[string] countConjunctions(string[] words) {
    string[] conjunctions = [
        "and", "but", "or", "because", "although", "while", "if", "unless", 
        "since", "so", "therefore", "yet", "however", "nevertheless", "furthermore", "moreover", "consequently", 
        "thus", "as", "before", "after", "during", "until"
    ];

    int[string] conjunctionFreq;
    foreach (word; words) {
        string loweredWord = word.toLower;

        if (conjunctions.canFind(loweredWord)) {
            conjunctionFreq[loweredWord]++;
        }
    }

    return conjunctionFreq;
}
