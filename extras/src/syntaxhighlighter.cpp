#include "syntaxhighlighter.h"
#include <QQuickTextDocument>

SyntaxHighlighter::SyntaxHighlighter(QObject* parent)
    : QSyntaxHighlighter(parent)
{}

// ── Public API ────────────────────────────────────────────────────────────────

QQuickTextDocument* SyntaxHighlighter::quickDocument() const { return m_quickDoc; }

void SyntaxHighlighter::setQuickDocument(QQuickTextDocument* doc)
{
    if (m_quickDoc == doc) return;
    m_quickDoc = doc;
    setDocument(doc ? doc->textDocument() : nullptr);
    emit documentChanged();
}

QString SyntaxHighlighter::language() const { return m_language; }

void SyntaxHighlighter::setLanguage(const QString& lang)
{
    const QString lower = lang.toLower();
    if (m_language == lower) return;
    m_language = lower;
    rebuildRules();
    emit languageChanged();
    rehighlight();
}

bool SyntaxHighlighter::darkMode() const { return m_darkMode; }

void SyntaxHighlighter::setDarkMode(bool dark)
{
    if (m_darkMode == dark) return;
    m_darkMode = dark;
    rebuildRules();
    emit darkModeChanged();
    rehighlight();
}

// ── Highlighting ──────────────────────────────────────────────────────────────

void SyntaxHighlighter::highlightBlock(const QString& text)
{
    // Single-line rules (keywords, strings, inline comments, numbers)
    for (const auto& rule : m_rules) {
        auto it = rule.pattern.globalMatch(text);
        while (it.hasNext()) {
            const auto m = it.next();
            setFormat(m.capturedStart(rule.captureGroup),
                      m.capturedLength(rule.captureGroup),
                      rule.format);
        }
    }

    // Multi-line comment overlay — applied after single-line rules so it wins.
    // Each comment type tracks its own in-progress state via an independent bit flag.
    if (m_mlComments.isEmpty()) return;

    const int prevState = qMax(0, previousBlockState());
    int newState = 0;

    for (const auto& mlc : m_mlComments) {
        bool inComment = (prevState & mlc.stateFlag) != 0;
        int pos = 0;

        while (pos <= text.length()) {
            if (inComment) {
                const auto endMatch = mlc.endPat.match(text, pos);
                if (!endMatch.hasMatch()) {
                    setFormat(pos, text.length() - pos, mlc.format);
                    newState |= mlc.stateFlag;
                    break;
                }
                setFormat(pos, endMatch.capturedEnd() - pos, mlc.format);
                inComment = false;
                pos = endMatch.capturedEnd();
            } else {
                const auto startMatch = mlc.startPat.match(text, pos);
                if (!startMatch.hasMatch()) break;
                inComment = true;
                pos = startMatch.capturedStart();
            }
        }
    }

    setCurrentBlockState(newState);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

QTextCharFormat SyntaxHighlighter::fmt(const QString& dark, const QString& light,
                                        bool bold, bool italic) const
{
    QTextCharFormat f;
    f.setForeground(QColor(m_darkMode ? dark : light));
    if (bold)   f.setFontWeight(QFont::Bold);
    if (italic) f.setFontItalic(true);
    return f;
}

void SyntaxHighlighter::addKeywords(const QStringList& keywords, const QTextCharFormat& f)
{
    for (const QString& kw : keywords) {
        Rule r;
        r.pattern = QRegularExpression(
            QStringLiteral(R"(\b)") + QRegularExpression::escape(kw) + QStringLiteral(R"(\b)"),
            QRegularExpression::CaseInsensitiveOption);
        r.format = f;
        m_rules.append(r);
    }
}

void SyntaxHighlighter::addMultilineComment(const QString& open, const QString& close,
                                             const QTextCharFormat& f)
{
    MultilineComment mlc;
    mlc.startPat  = QRegularExpression(QRegularExpression::escape(open));
    mlc.endPat    = QRegularExpression(QRegularExpression::escape(close));
    mlc.format    = f;
    // Assign next available power-of-two flag
    mlc.stateFlag = m_mlComments.isEmpty() ? 1 : (m_mlComments.last().stateFlag << 1);
    m_mlComments.append(mlc);
}

void SyntaxHighlighter::rebuildRules()
{
    m_rules.clear();
    m_mlComments.clear();

    const QString& l = m_language;
    if      (l == "sql")
        buildSqlRules();
    else if (l == "qml" || l == "js" || l == "javascript" || l == "ts" || l == "typescript")
        buildQmlJsRules();
    else if (l == "python" || l == "py")
        buildPythonRules();
    else if (l == "json")
        buildJsonRules();
    else if (l == "bash" || l == "sh" || l == "shell")
        buildBashRules();
    else if (l == "cpp" || l == "c++" || l == "c" || l == "h" || l == "hpp")
        buildCppRules();
    else if (l == "java")
        buildJavaRules();
    else if (l == "rust" || l == "rs")
        buildRustRules();
    else if (l == "go" || l == "golang")
        buildGoRules();
    else if (l == "html" || l == "htm")
        buildHtmlRules();
    else if (l == "css" || l == "scss" || l == "less")
        buildCssRules();
    else if (l == "yaml" || l == "yml")
        buildYamlRules();
    else if (l == "xml" || l == "svg" || l == "xaml")
        buildXmlRules();
}

// ── Language rule builders ────────────────────────────────────────────────────

void SyntaxHighlighter::buildSqlRules()
{
    const auto kwFmt  = fmt("#ff7b72", "#cf222e", true);
    const auto typFmt = fmt("#ffa657", "#953800");
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto cmmFmt = fmt("#8b949e", "#6e7781", false, true);

    addMultilineComment("/*", "*/", cmmFmt);

    addKeywords({
        "SELECT","FROM","WHERE","INSERT","INTO","UPDATE","DELETE","SET",
        "CREATE","DROP","ALTER","TABLE","INDEX","VIEW","TRIGGER","PROCEDURE","FUNCTION",
        "BEGIN","END","COMMIT","ROLLBACK","TRANSACTION","SAVEPOINT",
        "JOIN","LEFT","RIGHT","INNER","OUTER","CROSS","FULL","ON","USING",
        "AS","IN","NOT","AND","OR","IS","NULL","LIKE","ILIKE","BETWEEN","EXISTS",
        "HAVING","GROUP","ORDER","BY","LIMIT","OFFSET","DISTINCT","ALL","TOP",
        "UNION","INTERSECT","EXCEPT","WITH","RECURSIVE",
        "CASE","WHEN","THEN","ELSE","IF","LOOP","WHILE","FOR","RETURN","RETURNS",
        "VALUES","DEFAULT","PRIMARY","KEY","FOREIGN","REFERENCES","UNIQUE","CHECK",
        "CONSTRAINT","COLUMN","ADD","MODIFY","RENAME","TRUNCATE","GRANT","REVOKE",
        "DECLARE","CURSOR","FETCH","OPEN","CLOSE","EXECUTE","CALL","REPLACE","MERGE",
        "COUNT","SUM","AVG","MIN","MAX","COALESCE","NULLIF","CAST","CONVERT",
        "SUBSTRING","SUBSTR","UPPER","LOWER","TRIM","LENGTH",
        "NOW","CURRENT_TIMESTAMP","CURRENT_DATE","CURRENT_TIME",
        "ROW_NUMBER","RANK","DENSE_RANK","OVER","PARTITION","WINDOW","FILTER",
        "DATABASE","SCHEMA"
    }, kwFmt);

    addKeywords({
        "INT","INTEGER","BIGINT","SMALLINT","TINYINT","FLOAT","DOUBLE","REAL",
        "DECIMAL","NUMERIC","CHAR","VARCHAR","NVARCHAR","TEXT","CLOB","BLOB",
        "DATE","TIME","DATETIME","TIMESTAMP","TIMESTAMPTZ","BOOLEAN","BOOL",
        "SERIAL","BIGSERIAL","UUID","JSON","JSONB","ARRAY","BYTEA","BIT","MONEY"
    }, typFmt);

    Rule str;
    str.pattern = QRegularExpression(R"('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")");
    str.format  = strFmt;
    m_rules.append(str);

    Rule num;
    num.pattern = QRegularExpression(R"(\b\d+(\.\d+)?\b)");
    num.format  = numFmt;
    m_rules.append(num);

    Rule slc;
    slc.pattern = QRegularExpression(R"(--.*)");
    slc.format  = cmmFmt;
    m_rules.append(slc);
}

void SyntaxHighlighter::buildQmlJsRules()
{
    const auto kwFmt  = fmt("#ff7b72", "#cf222e", true);
    const auto typFmt = fmt("#ffa657", "#953800");
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto cmmFmt = fmt("#8b949e", "#6e7781", false, true);
    const auto prpFmt = fmt("#d2a8ff", "#8250df");

    addMultilineComment("/*", "*/", cmmFmt);

    addKeywords({
        "break","case","catch","continue","debugger","default","delete","do",
        "else","finally","for","function","if","in","instanceof","new","return",
        "switch","this","throw","try","typeof","var","void","while","with",
        "let","const","class","extends","import","export","from","of","async","await",
        "yield","super","static","get","set","null","undefined","true","false",
        "property","signal","readonly","alias","required","pragma","component","on"
    }, kwFmt);

    addKeywords({
        "String","Number","Boolean","Object","Array","Function","Symbol","BigInt",
        "Promise","Error","TypeError","RangeError","Math","JSON","Date","RegExp",
        "Map","Set","WeakMap","WeakSet","console",
        "Item","Rectangle","Text","Image","MouseArea","Column","Row","Grid","Flow",
        "Loader","Repeater","ListView","GridView","Flickable","Component","QtObject",
        "Timer","NumberAnimation","ColorAnimation","SequentialAnimation",
        "ParallelAnimation","Behavior","PropertyAnimation","State","Transition",
        "Connections","Window","ApplicationWindow","Dialog","Popup"
    }, typFmt);

    Rule prp;
    prp.pattern      = QRegularExpression(R"(\bproperty\s+\w+\s+(\w+)\b)");
    prp.captureGroup = 1;
    prp.format       = prpFmt;
    m_rules.append(prp);

    Rule tpl;
    tpl.pattern = QRegularExpression(R"(`(?:[^`\\]|\\.)*`)");
    tpl.format  = strFmt;
    m_rules.append(tpl);

    Rule str;
    str.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')");
    str.format  = strFmt;
    m_rules.append(str);

    Rule num;
    num.pattern = QRegularExpression(R"(\b\d+(\.\d+)?([eE][+-]?\d+)?\b|0x[0-9a-fA-F]+\b)");
    num.format  = numFmt;
    m_rules.append(num);

    Rule slc;
    slc.pattern = QRegularExpression(R"(//[^\n]*)");
    slc.format  = cmmFmt;
    m_rules.append(slc);
}

void SyntaxHighlighter::buildPythonRules()
{
    const auto kwFmt  = fmt("#ff7b72", "#cf222e", true);
    const auto typFmt = fmt("#ffa657", "#953800");
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto cmmFmt = fmt("#8b949e", "#6e7781", false, true);
    const auto decFmt = fmt("#d2a8ff", "#8250df");

    addKeywords({
        "and","as","assert","async","await","break","class","continue","def",
        "del","elif","else","except","False","finally","for","from","global",
        "if","import","in","is","lambda","None","nonlocal","not","or","pass",
        "raise","return","True","try","while","with","yield"
    }, kwFmt);

    addKeywords({
        "int","float","str","bool","list","dict","set","tuple","bytes","bytearray",
        "type","object","property","classmethod","staticmethod","super","range",
        "len","print","input","open","zip","map","filter","enumerate","sorted",
        "reversed","min","max","sum","abs","round","isinstance","issubclass",
        "hasattr","getattr","setattr","callable","iter","next",
        "Exception","ValueError","TypeError","KeyError","IndexError",
        "AttributeError","RuntimeError","StopIteration","OSError","FileNotFoundError"
    }, typFmt);

    Rule dec;
    dec.pattern = QRegularExpression(R"(@\w+)");
    dec.format  = decFmt;
    m_rules.append(dec);

    Rule tqs;
    tqs.pattern = QRegularExpression(R"(""".*?"""|'''.*?''')");
    tqs.format  = strFmt;
    m_rules.append(tqs);

    Rule str;
    str.pattern = QRegularExpression(R"([fFrRbBuU]?"(?:[^"\\]|\\.)*"|[fFrRbBuU]?'(?:[^'\\]|\\.)*')");
    str.format  = strFmt;
    m_rules.append(str);

    Rule num;
    num.pattern = QRegularExpression(R"(\b\d+(\.\d+)?([eE][+-]?\d+)?\b)");
    num.format  = numFmt;
    m_rules.append(num);

    Rule cmt;
    cmt.pattern = QRegularExpression(R"(#[^\n]*)");
    cmt.format  = cmmFmt;
    m_rules.append(cmt);
}

void SyntaxHighlighter::buildJsonRules()
{
    const auto keyFmt = fmt("#d2a8ff", "#8250df");
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto kwFmt  = fmt("#ff7b72", "#cf222e", true);

    Rule str;
    str.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*")");
    str.format  = strFmt;
    m_rules.append(str);

    Rule num;
    num.pattern = QRegularExpression(R"(\b-?\d+(\.\d+)?([eE][+-]?\d+)?\b)");
    num.format  = numFmt;
    m_rules.append(num);

    addKeywords({"true","false","null"}, kwFmt);

    // Keys last so they override the string colour
    Rule key;
    key.pattern      = QRegularExpression(R"(("(?:[^"\\]|\\.)*")\s*:)");
    key.captureGroup = 1;
    key.format       = keyFmt;
    m_rules.append(key);
}

void SyntaxHighlighter::buildBashRules()
{
    const auto kwFmt  = fmt("#ff7b72", "#cf222e", true);
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto cmmFmt = fmt("#8b949e", "#6e7781", false, true);
    const auto varFmt = fmt("#ffa657", "#953800");

    addKeywords({
        "if","then","else","elif","fi","for","while","do","done",
        "case","esac","in","function","return","local","export","unset",
        "echo","printf","read","exit","break","continue","shift","source",
        "true","false","test","select","until","trap","declare","typeset"
    }, kwFmt);

    Rule var;
    var.pattern = QRegularExpression(R"(\$\{?\w+\}?)");
    var.format  = varFmt;
    m_rules.append(var);

    Rule dstr;
    dstr.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*")");
    dstr.format  = strFmt;
    m_rules.append(dstr);

    Rule sstr;
    sstr.pattern = QRegularExpression(R"('[^']*')");
    sstr.format  = strFmt;
    m_rules.append(sstr);

    Rule num;
    num.pattern = QRegularExpression(R"(\b\d+\b)");
    num.format  = numFmt;
    m_rules.append(num);

    Rule cmt;
    cmt.pattern = QRegularExpression(R"(#[^\n]*)");
    cmt.format  = cmmFmt;
    m_rules.append(cmt);
}

void SyntaxHighlighter::buildCppRules()
{
    const auto kwFmt  = fmt("#ff7b72", "#cf222e", true);
    const auto typFmt = fmt("#ffa657", "#953800");
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto cmmFmt = fmt("#8b949e", "#6e7781", false, true);
    const auto preFmt = fmt("#d2a8ff", "#8250df");

    addMultilineComment("/*", "*/", cmmFmt);

    addKeywords({
        "auto","break","case","catch","class","const","constexpr","consteval",
        "constinit","continue","co_await","co_return","co_yield","default","delete",
        "do","else","enum","explicit","export","extern","false","for","friend","goto",
        "if","inline","namespace","new","nullptr","operator","private","protected",
        "public","register","return","sizeof","static","struct","switch","template",
        "this","throw","true","try","typedef","typename","union","using","virtual",
        "volatile","while","override","final","noexcept","decltype","static_assert",
        "thread_local","concept","requires","mutable"
    }, kwFmt);

    addKeywords({
        "void","bool","char","short","int","long","float","double",
        "signed","unsigned","wchar_t","char8_t","char16_t","char32_t",
        "size_t","ptrdiff_t","nullptr_t",
        "int8_t","int16_t","int32_t","int64_t",
        "uint8_t","uint16_t","uint32_t","uint64_t",
        "string","wstring","string_view",
        "vector","list","deque","array","span","queue","stack",
        "map","unordered_map","set","unordered_set","multimap","multiset",
        "pair","tuple","optional","variant","any","expected",
        "shared_ptr","unique_ptr","weak_ptr","function","thread","mutex"
    }, typFmt);

    Rule pre;
    pre.pattern = QRegularExpression(R"(^\s*#\s*\w+)");
    pre.format  = preFmt;
    m_rules.append(pre);

    Rule str;
    str.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*")");
    str.format  = strFmt;
    m_rules.append(str);

    Rule chr;
    chr.pattern = QRegularExpression(R"('(?:[^'\\]|\\.)')");
    chr.format  = strFmt;
    m_rules.append(chr);

    Rule num;
    num.pattern = QRegularExpression(R"(\b\d+(\.\d+)?([eE][+-]?\d+)?[fFlLuU]*\b|0x[0-9a-fA-F]+[lLuU]*\b|0b[01]+[lLuU]*\b)");
    num.format  = numFmt;
    m_rules.append(num);

    Rule slc;
    slc.pattern = QRegularExpression(R"(//[^\n]*)");
    slc.format  = cmmFmt;
    m_rules.append(slc);
}

void SyntaxHighlighter::buildJavaRules()
{
    const auto kwFmt  = fmt("#ff7b72", "#cf222e", true);
    const auto typFmt = fmt("#ffa657", "#953800");
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto cmmFmt = fmt("#8b949e", "#6e7781", false, true);
    const auto annFmt = fmt("#d2a8ff", "#8250df");

    addMultilineComment("/*", "*/", cmmFmt);

    addKeywords({
        "abstract","assert","break","case","catch","class","const","continue",
        "default","do","else","enum","extends","final","finally","for","goto",
        "if","implements","import","instanceof","interface","native","new",
        "null","package","private","protected","public","return","sealed",
        "static","strictfp","super","switch","synchronized","this","throw",
        "throws","transient","true","false","try","var","void","volatile","while",
        "permits","record","yield","module","requires","exports","opens","uses","provides"
    }, kwFmt);

    addKeywords({
        "boolean","byte","char","double","float","int","long","short",
        "String","Integer","Long","Double","Float","Boolean","Character","Byte","Short",
        "Object","Class","System","Math","Thread","Runnable",
        "Exception","RuntimeException","Error","Throwable",
        "ArrayList","LinkedList","HashMap","TreeMap","HashSet","TreeSet","LinkedHashMap",
        "List","Map","Set","Queue","Deque","Collection","Iterable","Iterator",
        "Optional","Stream","Collectors","Arrays","Objects","Collections",
        "StringBuilder","StringBuffer","Comparable","AutoCloseable","Serializable"
    }, typFmt);

    Rule ann;
    ann.pattern = QRegularExpression(R"(@\w+)");
    ann.format  = annFmt;
    m_rules.append(ann);

    Rule tbl;
    tbl.pattern = QRegularExpression(R"(""".*?""")");
    tbl.format  = strFmt;
    m_rules.append(tbl);

    Rule str;
    str.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')");
    str.format  = strFmt;
    m_rules.append(str);

    Rule num;
    num.pattern = QRegularExpression(R"(\b\d[\d_]*(\.\d[\d_]*)?([eE][+-]?\d+)?[fFdDlL]?\b|0x[0-9a-fA-F_]+[lL]?\b|0b[01_]+[lL]?\b)");
    num.format  = numFmt;
    m_rules.append(num);

    Rule slc;
    slc.pattern = QRegularExpression(R"(//[^\n]*)");
    slc.format  = cmmFmt;
    m_rules.append(slc);
}

void SyntaxHighlighter::buildRustRules()
{
    const auto kwFmt  = fmt("#ff7b72", "#cf222e", true);
    const auto typFmt = fmt("#ffa657", "#953800");
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto cmmFmt = fmt("#8b949e", "#6e7781", false, true);
    const auto macFmt = fmt("#d2a8ff", "#8250df");

    addMultilineComment("/*", "*/", cmmFmt);

    addKeywords({
        "as","async","await","break","const","continue","crate","dyn","else",
        "enum","extern","false","fn","for","if","impl","in","let","loop",
        "match","mod","move","mut","pub","ref","return","self","Self","static",
        "struct","super","trait","true","type","unsafe","use","where","while",
        "abstract","become","box","do","final","macro","override","priv",
        "try","typeof","unsized","virtual","yield"
    }, kwFmt);

    addKeywords({
        "i8","i16","i32","i64","i128","isize",
        "u8","u16","u32","u64","u128","usize",
        "f32","f64","bool","char","str",
        "String","Vec","HashMap","HashSet","BTreeMap","BTreeSet",
        "Option","Result","Box","Rc","Arc","Cell","RefCell","Mutex","RwLock",
        "Iterator","IntoIterator","From","Into","Clone","Copy","Debug","Display",
        "Fn","FnMut","FnOnce","Send","Sync","Default","PartialEq","Eq",
        "PartialOrd","Ord","Hash","Drop"
    }, typFmt);

    // Macros: identifier followed by !
    Rule mac;
    mac.pattern = QRegularExpression(R"(\b\w+!)");
    mac.format  = macFmt;
    m_rules.append(mac);

    // Raw strings r"..." and r#"..."#
    Rule rstr;
    rstr.pattern = QRegularExpression(R"(r#*".*?"#*)");
    rstr.format  = strFmt;
    m_rules.append(rstr);

    Rule str;
    str.pattern = QRegularExpression(R"(b?"(?:[^"\\]|\\.)*")");
    str.format  = strFmt;
    m_rules.append(str);

    Rule num;
    num.pattern = QRegularExpression(R"(\b\d[\d_]*(\.\d[\d_]*)?([eE][+-]?\d[\d_]*)?(f32|f64|i8|i16|i32|i64|i128|isize|u8|u16|u32|u64|u128|usize)?\b|0x[0-9a-fA-F_]+|0o[0-7_]+|0b[01_]+)");
    num.format  = numFmt;
    m_rules.append(num);

    // Lifetimes ('a, 'static) — after numbers so char literals don't conflict
    Rule lft;
    lft.pattern = QRegularExpression(R"('[a-zA-Z_]\w*\b)");
    lft.format  = typFmt;
    m_rules.append(lft);

    Rule slc;
    slc.pattern = QRegularExpression(R"(//[^\n]*)");
    slc.format  = cmmFmt;
    m_rules.append(slc);
}

void SyntaxHighlighter::buildGoRules()
{
    const auto kwFmt  = fmt("#ff7b72", "#cf222e", true);
    const auto typFmt = fmt("#ffa657", "#953800");
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto cmmFmt = fmt("#8b949e", "#6e7781", false, true);

    addMultilineComment("/*", "*/", cmmFmt);

    addKeywords({
        "break","case","chan","const","continue","default","defer","else",
        "fallthrough","for","func","go","goto","if","import","interface",
        "map","package","range","return","select","struct","switch","type","var"
    }, kwFmt);

    addKeywords({
        "bool","byte","complex64","complex128","error","float32","float64",
        "int","int8","int16","int32","int64","rune","string",
        "uint","uint8","uint16","uint32","uint64","uintptr",
        "nil","true","false","iota",
        "append","cap","close","complex","copy","delete","imag","len",
        "make","new","panic","print","println","real","recover"
    }, typFmt);

    // Raw string literals (backtick)
    Rule rstr;
    rstr.pattern = QRegularExpression(R"(`[^`]*`)");
    rstr.format  = strFmt;
    m_rules.append(rstr);

    Rule str;
    str.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*")");
    str.format  = strFmt;
    m_rules.append(str);

    Rule chr;
    chr.pattern = QRegularExpression(R"('(?:[^'\\]|\\.)')");
    chr.format  = strFmt;
    m_rules.append(chr);

    Rule num;
    num.pattern = QRegularExpression(R"(\b\d+(\.\d+)?([eE][+-]?\d+)?\b|0x[0-9a-fA-F]+\b|0o[0-7]+\b|0b[01]+\b)");
    num.format  = numFmt;
    m_rules.append(num);

    Rule slc;
    slc.pattern = QRegularExpression(R"(//[^\n]*)");
    slc.format  = cmmFmt;
    m_rules.append(slc);
}

void SyntaxHighlighter::buildHtmlRules()
{
    const auto tagFmt  = fmt("#7ee787", "#116329");
    const auto attrFmt = fmt("#ffa657", "#953800");
    const auto strFmt  = fmt("#a5d6ff", "#0a3069");
    const auto cmmFmt  = fmt("#8b949e", "#6e7781", false, true);
    const auto dtypFmt = fmt("#d2a8ff", "#8250df");

    addMultilineComment("<!--", "-->", cmmFmt);

    Rule dt;
    dt.pattern = QRegularExpression(R"(<!DOCTYPE[^>]*>)", QRegularExpression::CaseInsensitiveOption);
    dt.format  = dtypFmt;
    m_rules.append(dt);

    Rule tag;
    tag.pattern = QRegularExpression(R"(</?[\w:-]+)");
    tag.format  = tagFmt;
    m_rules.append(tag);

    Rule attr;
    attr.pattern      = QRegularExpression(R"(\s([\w:-]+)\s*=)");
    attr.captureGroup = 1;
    attr.format       = attrFmt;
    m_rules.append(attr);

    Rule val;
    val.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')");
    val.format  = strFmt;
    m_rules.append(val);

    Rule close;
    close.pattern = QRegularExpression(R"(/?>)");
    close.format  = tagFmt;
    m_rules.append(close);
}

void SyntaxHighlighter::buildCssRules()
{
    const auto propFmt = fmt("#a5d6ff", "#0a3069");
    const auto valFmt  = fmt("#ffa657", "#953800");
    const auto numFmt  = fmt("#79c0ff", "#0550ae");
    const auto strFmt  = fmt("#a5d6ff", "#0a3069");
    const auto cmmFmt  = fmt("#8b949e", "#6e7781", false, true);
    const auto atFmt   = fmt("#ff7b72", "#cf222e", true);
    const auto selFmt  = fmt("#7ee787", "#116329");

    addMultilineComment("/*", "*/", cmmFmt);

    // At-rules (@media, @keyframes, …)
    Rule atr;
    atr.pattern = QRegularExpression(R"(@[\w-]+)");
    atr.format  = atFmt;
    m_rules.append(atr);

    // Strings
    Rule str;
    str.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')");
    str.format  = strFmt;
    m_rules.append(str);

    // Numbers with optional units
    Rule num;
    num.pattern = QRegularExpression(R"(-?\d+(\.\d+)?(px|em|rem|vh|vw|vmin|vmax|%|pt|cm|mm|in|deg|rad|turn|s|ms|fr|ch|ex)?\b)");
    num.format  = numFmt;
    m_rules.append(num);

    // Hex colours
    Rule col;
    col.pattern = QRegularExpression(R"(#[0-9a-fA-F]{3,8}\b)");
    col.format  = numFmt;
    m_rules.append(col);

    // Pseudo-classes / pseudo-elements
    Rule pseudo;
    pseudo.pattern = QRegularExpression(R"(:+[\w-]+)");
    pseudo.format  = selFmt;
    m_rules.append(pseudo);

    // Property names (word/dash followed by colon inside a rule block)
    Rule prop;
    prop.pattern      = QRegularExpression(R"(\b([\w-]+)\s*:(?!:))");
    prop.captureGroup = 1;
    prop.format       = propFmt;
    m_rules.append(prop);
}

void SyntaxHighlighter::buildYamlRules()
{
    const auto keyFmt = fmt("#d2a8ff", "#8250df");
    const auto strFmt = fmt("#a5d6ff", "#0a3069");
    const auto numFmt = fmt("#79c0ff", "#0550ae");
    const auto kwFmt  = fmt("#ff7b72", "#cf222e");
    const auto cmmFmt = fmt("#8b949e", "#6e7781", false, true);
    const auto ancFmt = fmt("#ffa657", "#953800");

    // Document markers
    Rule doc;
    doc.pattern = QRegularExpression(R"(^---$|^\.\.\.$)");
    doc.format  = kwFmt;
    m_rules.append(doc);

    // Anchors (&name) and aliases (*name)
    Rule anc;
    anc.pattern = QRegularExpression(R"([&*]\w+)");
    anc.format  = ancFmt;
    m_rules.append(anc);

    // Quoted strings
    Rule str;
    str.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')");
    str.format  = strFmt;
    m_rules.append(str);

    // Special scalar values
    addKeywords({"true","false","null","yes","no","on","off"}, kwFmt);

    // Numbers
    Rule num;
    num.pattern = QRegularExpression(R"(\b-?\d+(\.\d+)?([eE][+-]?\d+)?\b)");
    num.format  = numFmt;
    m_rules.append(num);

    // Keys — applied after strings so quoted keys get key colour
    Rule key;
    key.pattern      = QRegularExpression(R"(^\s*([\w][\w\s.-]*?)\s*:)");
    key.captureGroup = 1;
    key.format       = keyFmt;
    m_rules.append(key);

    Rule cmt;
    cmt.pattern = QRegularExpression(R"(#[^\n]*)");
    cmt.format  = cmmFmt;
    m_rules.append(cmt);
}

void SyntaxHighlighter::buildXmlRules()
{
    const auto tagFmt  = fmt("#7ee787", "#116329");
    const auto attrFmt = fmt("#ffa657", "#953800");
    const auto strFmt  = fmt("#a5d6ff", "#0a3069");
    const auto cmmFmt  = fmt("#8b949e", "#6e7781", false, true);
    const auto piFmt   = fmt("#d2a8ff", "#8250df");

    addMultilineComment("<!--", "-->", cmmFmt);

    // Processing instructions <?...?>
    Rule pi;
    pi.pattern = QRegularExpression(R"(<\?.*?\?>)");
    pi.format  = piFmt;
    m_rules.append(pi);

    // CDATA sections
    Rule cdata;
    cdata.pattern = QRegularExpression(R"(<!\[CDATA\[.*?\]\]>)");
    cdata.format  = strFmt;
    m_rules.append(cdata);

    Rule tag;
    tag.pattern = QRegularExpression(R"(</?[\w:.-]+)");
    tag.format  = tagFmt;
    m_rules.append(tag);

    Rule attr;
    attr.pattern      = QRegularExpression(R"(\s([\w:.-]+)\s*=)");
    attr.captureGroup = 1;
    attr.format       = attrFmt;
    m_rules.append(attr);

    Rule val;
    val.pattern = QRegularExpression(R"("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')");
    val.format  = strFmt;
    m_rules.append(val);

    Rule close;
    close.pattern = QRegularExpression(R"(/?>)");
    close.format  = tagFmt;
    m_rules.append(close);
}
