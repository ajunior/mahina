#pragma once

#include <QAbstractTableModel>
#include <QByteArray>
#include <QHash>
#include <QStringList>
#include <QVariant>
#include <QVector>
#include <qqmlintegration.h>

// Minimal QAbstractTableModel showing what ModelTable expects from a model.
//
// ModelTable's cell delegate binds two roles by name:
//   "display" — the cell text
//   "isNull"  — true when the cell holds no value, so NULL renders distinctly
//               from an empty string
//
// A model that omits "isNull" will fail to instantiate ModelTable's delegate
// (the property is required), which is why QML-side TableModel cannot drive
// this component — TableModelColumn only maps Qt's built-in item roles.
//
// Sorting is optional: ModelTable calls sort() only if the model exposes it.
class DemoTableModel : public QAbstractTableModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles {
        IsNullRole = Qt::UserRole + 1
    };

    explicit DemoTableModel(QObject *parent = nullptr);

    int      rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int      columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant headerData(int section, Qt::Orientation orientation,
                        int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) override;

private:
    QStringList                m_headers;
    QVector<QVector<QVariant>> m_rows;
};
