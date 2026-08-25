#include "DemoTableModel.h"

#include <algorithm>

DemoTableModel::DemoTableModel(QObject *parent)
    : QAbstractTableModel(parent)
{
    m_headers = { QStringLiteral("Component"),
                  QStringLiteral("Kind"),
                  QStringLiteral("Version"),
                  QStringLiteral("Notes") };

    // A null QVariant is a genuinely absent value; an empty QString is a
    // present-but-empty one. ModelTable renders the two differently, which is
    // the distinction the "isNull" role exists to carry.
    m_rows = {
        { QStringLiteral("mahina"),         QStringLiteral("QML / C++"),     QStringLiteral("0.45.0"), QVariant() },
        { QStringLiteral("qub"),            QStringLiteral("QML / C++"),     QVariant(),              QStringLiteral("SQL client") },
        { QStringLiteral("Inter"),          QStringLiteral("Variable font"), QStringLiteral("4.0"),   QStringLiteral("bundled") },
        { QStringLiteral("JetBrains Mono"), QStringLiteral("Variable font"), QStringLiteral("2.3"),   QStringLiteral("bundled") },
        { QStringLiteral("Phosphor"),       QStringLiteral("Icon font"),     QVariant(),              QStringLiteral("900+ glyphs") },
        { QStringLiteral("MahinaExtras"),   QStringLiteral("C++"),           QVariant(),              QStringLiteral("optional") },
        { QStringLiteral("(empty string)"), QStringLiteral("demo"),          QString(),               QStringLiteral("empty, not NULL") },
    };
}

int DemoTableModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_rows.size();
}

int DemoTableModel::columnCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_headers.size();
}

QVariant DemoTableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_rows.size())
        return {};

    const QVector<QVariant> &row = m_rows.at(index.row());
    if (index.column() < 0 || index.column() >= row.size())
        return {};

    const QVariant &cell = row.at(index.column());

    switch (role) {
    case Qt::DisplayRole:
        // Never hand back a null QVariant here — ModelTable's delegate takes
        // "display" as a required string. The null-ness travels via IsNullRole.
        return cell.isNull() ? QVariant(QString()) : cell;
    case IsNullRole:
        return cell.isNull();
    default:
        return {};
    }
}

QVariant DemoTableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (role != Qt::DisplayRole || orientation != Qt::Horizontal)
        return {};
    if (section < 0 || section >= m_headers.size())
        return {};
    return m_headers.at(section);
}

QHash<int, QByteArray> DemoTableModel::roleNames() const
{
    return {
        { Qt::DisplayRole, QByteArrayLiteral("display") },
        { IsNullRole,      QByteArrayLiteral("isNull")  },
    };
}

void DemoTableModel::sort(int column, Qt::SortOrder order)
{
    if (column < 0 || column >= m_headers.size())
        return;

    emit layoutAboutToBeChanged();

    std::stable_sort(m_rows.begin(), m_rows.end(),
                     [column, order](const QVector<QVariant> &a, const QVector<QVariant> &b) {
                         const QVariant &va = a.at(column);
                         const QVariant &vb = b.at(column);

                         // Nulls sort last regardless of direction, the way
                         // most SQL clients present them.
                         if (va.isNull() != vb.isNull())
                             return vb.isNull();
                         if (va.isNull())
                             return false;

                         const int cmp = QString::compare(va.toString(), vb.toString(),
                                                          Qt::CaseInsensitive);
                         return order == Qt::AscendingOrder ? cmp < 0 : cmp > 0;
                     });

    emit layoutChanged();
}
