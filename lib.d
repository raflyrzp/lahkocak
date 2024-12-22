module lib;

import std.stdio;
import std.file;
import std.regex;
import std.string;
import std.algorithm;
import std.conv;
import std.array;

struct ArticleData {
    string title;
    string content;
    int wordCount;
    int[string] wordFreq;
    int[string] conjunctionFreq;
    int[char] alphaNumericFreq;
}
string[] conjunctions = [
    "and", "but", "or", "because", "although", "while", "if", "unless", 
    "since", "so", "therefore", "yet", "however", "nevertheless", 
    "furthermore", "moreover", "consequently", "thus", "as", 
    "before", "after", "during", "until", "in", "on", "at", "by", 
    "with", "about", "against", "for", "to", "from", "under", "over", 
    "between", "among", "through", "into", "like", "as", "of", "without", "a", "is"
];

string cleanText(string text) {
    auto re = regex(r"\[\d+\]");
    auto reNonAlpha = regex(r"[^a-zA-Z\d\s:]");

    string cleanedText = replaceAll(text, re, " ");
    cleanedText = replaceAll(cleanedText, reNonAlpha, " ");

    return cleanedText;
}

string[] splitWords(string text) {
    string cleaned = cleanText(text);
    return cleaned.toLower.split();
}

int[string] wordOccurrence(string[] words) {
    int[string] wordFreq;
    foreach (word; words) wordFreq[word]++;
    return wordFreq;
}

int[char] alphaNumericOccurrence(string text) {
    int[char] alphaNumericFreq;
    foreach (char ch; text) {
        if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9')) {
            alphaNumericFreq[ch]++;
        }
    }
    return alphaNumericFreq;
}

int[string] countConjunctions(string[] words) {
    int[string] conjunctionFreq;
    foreach (word; words) {
        string loweredWord = word.toLower;
        if (conjunctions.canFind(loweredWord)) {
            conjunctionFreq[loweredWord]++;
        }
    }

    return conjunctionFreq;
}

string findBestArticle(string word1, string word2, ArticleData[string] textDB) {
    int minDistance = int.max;
    string bestArticle = "";

    foreach (fileName, articleData; textDB) {
        string[] words = splitWords(articleData.content);

        int lastPos1 = -1;
        int lastPos2 = -1;
        int closestDistance = int.max;

        for (int i = 0; i < words.length; i++) {
            if (words[i].toLower == word1.toLower) {
                lastPos1 = i;
                if (lastPos2 != -1) {
                    closestDistance = lastPos1 - lastPos2;
                }
            }
            if (words[i].toLower == word2.toLower) {
                lastPos2 = i;
                if (lastPos1 != -1) {
                    closestDistance = lastPos1 - lastPos2;
                }
            }
        }

        if (lastPos1 != -1 && lastPos2 != -1 && closestDistance < minDistance) {
            minDistance = closestDistance;
            bestArticle = fileName;
        }
    }

    return bestArticle;
}

string generateTitle(int[string] wordFreq) {
    string[] filteredWords;
    string title = "";
    int count = 0;
    int validWordsCount = 0;

    foreach (key, value; wordFreq) {
        if (!conjunctions.canFind(key.toLower)) {
            filteredWords ~= key;
        }
    }

    filteredWords.sort!((a, b) => wordFreq[b] < wordFreq[a]);

    string lastAddedWord = "";

    while (validWordsCount < 3 && count < filteredWords.length) {
        string currentWord = filteredWords[count];

        if (lastAddedWord != "" && (currentWord.startsWith(lastAddedWord) || lastAddedWord.startsWith(currentWord))) {
            count++; 
            continue;
        }

        title ~= currentWord ~ " ";
        lastAddedWord = currentWord;
        validWordsCount++;

        count++;
    }

    return title.strip(); 
}

int levenshteinDistance(string a, string b) {
    int m = cast(int)a.length;
    int n = cast(int)b.length;

    int[][] dp = new int[][](m + 1);
    foreach (i; 0..m + 1) {
        dp[i] = new int[](n + 1);
    }

    for (int i = 0; i <= m; i++) dp[i][0] = i;
    for (int j = 0; j <= n; j++) dp[0][j] = j;

    for(int i=1; i<=m; i++) {
        for(int j=1; j<=n; j++) {
            int cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
            dp[i][j] = min(dp[i - 1][j] + 1,
                           dp[i][j - 1] + 1,
                           dp[i - 1][j - 1] + cost);
        }
    }

    return dp[m][n];
}


string[] findLexicalSimilarWords(string queryWord, int[string] wordList) {
    int[string] distances;

    foreach (word, _; wordList) {
        distances[word] = levenshteinDistance(queryWord, word);
    }

    auto sortedWords = distances.byKeyValue
        .array
        .sort!((a, b) => a.value < b.value);

    string[] lexical;
    for(int i=0; i<5; i++) {
        lexical ~= sortedWords[i].key;
    }

    return lexical;
}

string[] findMostSimilarWords(string queryWord, int[string] wordList) {
    string[] lexical = findLexicalSimilarWords(queryWord, wordList);

    int minDistance = int.max;
    string word1, word2;

    for (int i = 0; i < lexical.length; i++) {
        for (int j = i + 1; j < lexical.length; j++) {
            int dist = levenshteinDistance(lexical[i], lexical[j]);
            if (dist < minDistance) {
                minDistance = dist;
                word1 = lexical[i];
                word2 = lexical[j];
            }
        }
    }

    return [word1, word2];
}