import 'dart:math';
import 'dart:io';
import 'dart:core';

class Dictionary {
  static int INT_SIZE = 32; // INT bit size
  static int NUM_CHARS = 26; // alphabetical chars
  static int NUM_INT = (7 * 26) ~/ (INT_SIZE - (INT_SIZE % 7)) + 1; // amount of INT(size) needed per word
  final List<WordBinary> _structures = <WordBinary>[];
  Dictionary(String source, {int wordSize: -1}) {
    final String T = source.substring(0, 100);
    String splitChar;
    if (_isCleanSplit(T.split('\n'))) splitChar = '\n';
    source.split(splitChar).forEach((String W) {
        if (W.isNotEmpty) addStructure(new WordBinary(W));
    });
}
  
void addStructure(WordBinary S) => _structures.add(S);
  
bool _isCleanSplit(List<String> T) {
    if (T.length <= 1) return false;
    final String S = T[1];
    final int min = 97, max = 97 + Dictionary.NUM_CHARS;
    final int J = S.codeUnits.firstWhere((int I) => (I < min || I >= max),orElse: () => null);
    return (J == null);
}
List<WordBinary> match(String W, int numBlanks) {
    final WordBinary S = new WordBinary(W);
    final List<WordBinary> allMatches = <WordBinary>[];
    final int len = _structures.length;
    WordBinary s;
    int i;
    for (i=0; i<len; i++) {
      s = _structures[i];
      if (s.matches(S, numBlanks)) allMatches.add(s);
    }
    return allMatches; 
}

List<WordBinary> anagrams(String W, int numBlanks) {
    final WordBinary S = new WordBinary(W);
    final List<WordBinary> allMatches = <WordBinary>[];
    final int len = _structures.length;
    WordBinary s;
    int i;
    for (i=0; i<len; i++) {
      s = _structures[i];
      if (s.isAnagramOf(S, numBlanks)) allMatches.add(s);
    }
    return allMatches;
  }
}

class WordBinary {
    final String word;
    String result;
    int total;
    List<int> segments;
    int wordLen;
    WordBinary(this.word) {
    wordLen = word.length;
    segments = toBinary();
    }
    bool isAnagramOf(WordBinary other, int numBlanks) {
        if (other.wordLen + numBlanks != wordLen) return false;
        return matches(other, numBlanks);
    }
    bool matches(WordBinary other, int numBlanks) {
    if (other.wordLen + numBlanks < wordLen) return false;
    for (int i=0; i<Dictionary.NUM_INT; i++) {
        numBlanks = _test(segments[i], other.segments[i], numBlanks);
        if (numBlanks == -1) return false;
    }
    return true;
}

int _test(int sA, int sB, int numBlanks) {
    if (sA == 0) return numBlanks;
    int M = (sB ^ sA) & sA;
    if (M == 0) return numBlanks;
    else if (numBlanks == 0) return -1;
    for (int N ;M > 0; M >>= 7) {
        N = M & 0x7F;
        if (N > 0) {
            switch (N) {
                case 1: case 2: case 4: case 8: case 16: case 32: case 64: numBlanks -= 1; 
                break;
                case 3: case 5: case 6: case 9: case 10: case 12: case 17: case 18: case 20:    
                case 24: case 33: case 34: case 36: case 40: case 48: case 65: case 66: case 68: 
                case 72: case 80: case 96: numBlanks -= 2; 
                break;
                case 7: case 11: case 13: case 14: case 19: case 21: case 22: case 25: case 26: 
                case 28: case 35: case 37: case 38: case 41: case 42: case 44: case 49: case 50: 
                case 52: case 56: case 67: case 69: case 70: case 73: case 74: case 76: case 81: 
                case 82: case 84: case 88: case 97: case 98: case 100: case 104: case 112: 
                numBlanks -= 3; 
                break;
                case 15: case 23: case 27: case 29: case 30: case 39: case 43: case 45: case 46: 
                case 51: case 53: case 54: case 57: case 58: case 60: case 71: case 75: case 77: 
                case 78: case 83: case 85: case 86: case 89: case 90: case 92: case 99: case 101: 
                case 102: case 105: case 106: case 108: case 113: case 114: case 116: case 120: 
                numBlanks -= 4; 
                break;
                case 31: case 47: case 55: case 59: case 61: case 62: case 79: case 87: case 91: 
                case 93: case 94: case 103: case 107: case 109: case 110: case 115: case 117: 
                case 118: case 121: case 122: case 124: numBlanks -= 5; 
                break;
                case 63: case 95: case 111: case 119: case 123: case 125: case 126: numBlanks -= 6; 
                break;
                case 127: numBlanks -= 7; 
                break;
            }
            if (numBlanks < 0) return -1;
        }
    }
    return numBlanks;
    }
  
List<int> toBinary() {
    final List<int> S = new List<int>(Dictionary.NUM_INT);
    final List<int> U = word.codeUnits;
    final List<int> C = new List<int>(Dictionary.NUM_CHARS);
    final int len = U.length;
    int i, j, k, l;
    for (i=0; i<len; i++) {
        j = U[i] - 97;
        if (C[j] == null) C[j] = 2;
        else C[j] *= 2;
     }
    for (i=j=k=l=0; i<Dictionary.NUM_CHARS; i++, k += 7) {
        if (k + 7 > Dictionary.INT_SIZE) {
        S[l++] = j;
        j = k = 0;
        }
        if (C[i] != null) j |= (C[i] - 1) << k;
     }
     S[l++] = j;
     return S;
}
String toString() => word;
}

void main() {
    final String C = new File('sowpods.txt').readAsStringSync();
    Dictionary D = new Dictionary(C);
    print("Your Tiles:");
    string input = stdin.readLineSync();
    print(match(D, input, 0, true));
}

const List<int> LETTER_VALS = const <int>[1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10];

List<WordBinary> match(Dictionary D, String V, int N, bool printReport) {
    Stopwatch S;
    print("Enter position");
    int position = int.parse(stdin.readLineSync());
    position=position-1;
    print("Enter character");
    char selectedLetter=stdin.readLineSync();
    if(position < 0 || position > V.length)
    {
    print("Invalid position, position ranges from 1 to wordLen");
    return null;
    }
    int i = V.indexOf(selectedLetter);
    if(i==-1)
    {
    print("Selected letter doesn't found in word");
    return null;
    }
    if (printReport) S = new Stopwatch()..start();
        print("Your Tiles are: $V ,Position is $position, Charater is $selectedLetter");
        final List<WordBinary> L = D.match(V, N);
        List<WordBinary> finalList = [];
        for(String wordd in L) {
            if(wordd.toString()[position.toInt()]==selectedLetter) {
        finalList.add(wordd);
        }
        }
      finalList.sort((WordBinary A, WordBinary B) {
      final int vA = A.word.codeUnits.fold(0, (int P, int C) => P + LETTER_VALS[C - 97]);
      final int vB = B.word.codeUnits.fold(0, (int P, int C) => P + LETTER_VALS[C - 97]);
      return vB.compareTo(vA);
    });
    int total = finalList.first.toString().codeUnits.fold(0, (int P, int C) => P + LETTER_VALS[C - 97]);
    print("Score : $total");
    return finalList.first;
}
List<WordBinary> anagrams(Dictionary D, String V, int N, bool printReport) {
    final List<WordBinary> L = D.anagrams(V, N);
    L.sort((WordBinary A, WordBinary B) {
    final int vA = A.word.codeUnits.fold(0, (int P, int C) => P + LETTER_VALS[C - 97]);
    final int vB = B.word.codeUnits.fold(0, (int P, int C) => P + LETTER_VALS[C - 97]);
    return vB.compareTo(vA);
    }
  );
  return L;
}
