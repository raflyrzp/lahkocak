module print;

import std.stdio;
import lib; 

void printArticleStats(string fileName, ArticleData articleData) {
    writeln("Article: ", fileName);
    writeln("Amount of words in article: ", articleData.wordCount);

    writeln("Word occurrences per article:");
    foreach (word, count; articleData.wordFreq) {
        writeln(word, ": ", count);
    }

    writeln("\nAlphanumeric occurrences per article:");
    foreach (ch, count; articleData.alphaNumericFreq) {
        writeln(ch, ": ", count);
    }

    writeln("\nDetected conjunctions in article:");
    foreach (conjunction, count; articleData.conjunctionFreq) {
        writeln(conjunction, ": ", count);
    }
}

void printGlobalStats(int totalWordCount, int[string] totalWordFreq, 
                    int[string] totalConjunctionFreq, int[char] globalAlphaNumericFreq) {
    writeln("\nTotal amount of words: ", totalWordCount);

    writeln("\nTotal word occurrences:");
    foreach (word, count; totalWordFreq) {
        writeln(word, ": ", count);
    }

    writeln("\nTotal detected conjunctions:");
    foreach (conjunction, count; totalConjunctionFreq) {
        writeln(conjunction, ": ", count);
    }

    writeln("\nGlobal alphanumeric occurrences:");
    foreach (ch, count; globalAlphaNumericFreq) {
        writeln(ch, ": ", count);
    }
}
