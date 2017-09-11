#include "modelschnellgaerverlauf.h"
#include "brauhelfer.h"
#include <QDateTime>

ModelSchnellgaerverlauf::ModelSchnellgaerverlauf(Brauhelfer* bh) :
    SqlTableModel(bh),
    bh(bh)
{
}

QVariant ModelSchnellgaerverlauf::dataExt(const QModelIndex &index) const
{
    QString field = fieldName(index.column());
    if (field == "Zeitstempel")
    {
        return QDateTime::fromString(QSqlTableModel::data(index).toString(), Qt::ISODate);
    }
    if (field == "Alc")
    {
        double sre = data(index.row(), "SW").toDouble();
        return BierCalc::alkohol(bh->sud()->getSWIst(), sre);
    }
    return QVariant();
}

bool ModelSchnellgaerverlauf::setDataExt(const QModelIndex &index, const QVariant &value)
{
    QModelIndex index2;
    QString field = fieldName(index.column());
    if (field == "Zeitstempel")
    {
        return QSqlTableModel::setData(index, value.toDateTime().toString(Qt::ISODate));
    }
    else if (field == "SW")
    {
        if (QSqlTableModel::setData(index, value))
        {
            index2 = this->index(index.row(), fieldIndex("Alc"));
            QSqlTableModel::setData(index2, dataExt(index2));
            if ((index.row() + 1) == rowCount() && bh->sud()->getBierWurdeGebraut())
                bh->sud()->setSWSchnellgaerprobe(value.toDouble());
            return true;
        }
    }
    return false;
}

QVariantMap ModelSchnellgaerverlauf::defaultValues() const
{
    int lastRow = rowCount() - 1;
    QVariantMap values;
    values.insert("SudID", bh->sud()->getId());
    values.insert("Zeitstempel", QDateTime::currentDateTime());
    if (lastRow >= 0)
    {
        values.insert("SW", data(lastRow, "SW"));
        values.insert("Temp", data(lastRow, "Temp"));
    }
    else
    {
        values.insert("SW", bh->sud()->getSWIst());
        values.insert("Temp", 20.0);
    }
    return values;
}