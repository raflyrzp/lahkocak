module main;

import std.stdio;
import std.file;
import std.string;
import std.algorithm;
import std.path;
import std.regex;
import lib;
import print;

void main() {
    string folderPath = "text_db";
    ArticleData[string] textDB;

    int totalWordCount = 0;
    int[string] totalWordFreq;
    int[string] totalConjunctionFreq;
    int[char] globalAlphaNumericFreq;

    foreach (entry; dirEntries(folderPath, SpanMode.shallow)) {
        if (entry.isFile) {
            string fileName = baseName(entry.name);
            string fileContent = readText(entry);

            string[] wordsInFile = splitWords(fileContent);
            int wordCountInFile = cast(int)wordsInFile.length;

            int[string] fileWordFreq = wordOccurrence(wordsInFile);
            int[string] fileConjunctionFreq = countConjunctions(wordsInFile);
            int[char] fileAlphaNumericFreq = alphaNumericOccurrence(fileContent);

            totalWordCount += wordCountInFile;
            foreach (word, count; fileWordFreq) totalWordFreq[word] += count;
            foreach (conjunction, count; fileConjunctionFreq) totalConjunctionFreq[conjunction] += count;
            foreach (ch, count; fileAlphaNumericFreq) globalAlphaNumericFreq[ch] += count;
            string title = generateTitle(fileWordFreq);

            textDB[fileName] = ArticleData(
                title: title,
                content: fileContent,
                wordCount: wordCountInFile,
                wordFreq: fileWordFreq,
                conjunctionFreq: fileConjunctionFreq,
                alphaNumericFreq: fileAlphaNumericFreq
            );

        }
    }
    //  print.printGlobalStats(totalWordCount, totalWordFreq, totalConjunctionFreq, globalAlphaNumericFreq);
    // print.printArticleStats("zen5", textDB["zen5"]);

    writeln("Enter your query...");
    string query1;
    readf("%s\n", query1);

    string[] queryWords = query1.split(" ");

    string bestArticle = findBestArticle(queryWords[0], queryWords[1], textDB);

    if (bestArticle != "") {
        writeln("The most relevant article is: ", bestArticle);
        writefln("with title: %s", textDB[bestArticle].title);
    } else {
        writeln("No matching articles found.");
    }

    writeln("Enter your query...");
    string query2;
    readf("%s\n", query2);

    string[] lexical = findLexicalSimilarWords(query2, totalWordFreq);
    writeln(lexical);
}
