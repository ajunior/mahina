#pragma once
#include <QSyntaxHighlighter>
#include <QTextCharFormat>
#include <QRegularExpression>
#include <QtQml/qqml.h>

class QQuickTextDocument;

class SyntaxHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QQuickTextDocument* document READ quickDocument WRITE setQuickDocument NOTIFY documentChanged)
    Q_PROPERTY(QString             language READ language      WRITE setLanguage      NOTIFY languageChanged)
    Q_PROPERTY(bool                darkMode READ darkMode      WRITE setDarkMode      NOTIFY darkModeChanged)

public:
    explicit SyntaxHighlighter(QObject* parent = nullptr);

    QQuickTextDocument* quickDocument() const;
    void setQuickDocument(QQuickTextDocument* doc);

    QString language() const;
    void setLanguage(const QString& lang);

    bool darkMode() const;
    void setDarkMode(bool dark);

signals:
    void documentChanged();
    void languageChanged();
    void darkModeChanged();

protected:
    void highlightBlock(const QString& text) override;

private:
    struct Rule {
        QRegularExpression pattern;
        int                captureGroup = 0;
        QTextCharFormat    format;
    };

    // Each multi-line comment type gets a unique power-of-two state flag so
    // multiple types (e.g. /* */ and <!-- -->) can coexist independently.
    struct MultilineComment {
        QRegularExpression startPat;
        QRegularExpression endPat;
        QTextCharFormat    format;
        int                stateFlag;
    };

    QQuickTextDocument*    m_quickDoc = nullptr;
    QString                m_language;
    bool                   m_darkMode = true;
    QList<Rule>            m_rules;
    QList<MultilineComment> m_mlComments;

    void rebuildRules();
    QTextCharFormat fmt(const QString& dark, const QString& light,
                        bool bold = false, bool italic = false) const;
    void addKeywords(const QStringList& keywords, const QTextCharFormat& f);
    void addMultilineComment(const QString& open, const QString& close,
                             const QTextCharFormat& f);

    void buildSqlRules();
    void buildQmlJsRules();
    void buildPythonRules();
    void buildJsonRules();
    void buildBashRules();
    void buildCppRules();
    void buildJavaRules();
    void buildRustRules();
    void buildGoRules();
    void buildHtmlRules();
    void buildCssRules();
    void buildYamlRules();
    void buildXmlRules();
};
