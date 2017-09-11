#ifndef MODELSUD_H
#define MODELSUD_H

#include "sqltablemodel.h"

class Brauhelfer;

// Weitere Zutaten Typen
#define EWZ_Typ_Honig 0
#define EWZ_Typ_Zucker 1
#define EWZ_Typ_Gewuerz 2
#define EWZ_Typ_Frucht 3
#define EWZ_Typ_Sonstiges 4
#define EWZ_Typ_Hopfen 100

// Weitere Zutaten Zugabezeitpunkt
#define EWZ_Zeitpunkt_Gaerung 0
#define EWZ_Zeitpunkt_Kochbeginn 1
#define EWZ_Zeitpunkt_Maischen 2

// Weitere Zutaten zugabestatus
#define EWZ_Zugabestatus_nichtZugegeben 0
#define EWZ_Zugabestatus_Zugegeben 1
#define EWZ_Zugabestatus_Entnommen 2

// Entnahmeindex
#define EWZ_Entnahmeindex_MitEntnahme 0
#define EWZ_Entnahmeindex_KeineEntnahme 1

// Weitere Zutaten Einheit
#define EWZ_Einheit_Kg 0
#define EWZ_Einheit_g 1

// Hefe Art
#define Hefe_Unbekannt 0
#define Hefe_Trocken 1
#define Hefe_Fluessig 2

class ModelSud : public SqlTableModel
{
    Q_OBJECT

public:
    ModelSud(Brauhelfer* bh, bool globalList);
    ~ModelSud();
    QVariant dataExt(const QModelIndex &index) const Q_DECL_OVERRIDE;
    bool setDataExt(const QModelIndex &index, const QVariant &value) Q_DECL_OVERRIDE;
private slots:
    void init();
    void valueChanged(const QModelIndex &index, const QVariant &value);
private:
    void updateIntermediateValues(int row);
    QVariant erg_Preis(const QModelIndex &index) const;
    QVariant SWIst(const QModelIndex &index) const;
    QVariant SREIst(const QModelIndex &index) const;
    QVariant CO2Ist(const QModelIndex &index) const;
    QVariant Spundungsdruck(const QModelIndex &index) const;
    QVariant Gruenschlauchzeitpunkt(const QModelIndex &index) const;
    QVariant SpeiseNoetig(const QModelIndex &index) const;
    QVariant SpeiseAnteil(const QModelIndex &index) const;
    QVariant ZuckerAnteil(const QModelIndex &index) const;
    QVariant ReifezeitDelta(const QModelIndex &index) const;
    QVariant AbfuellenBereitZutaten(const QModelIndex &index) const;
    QVariant MengeSollKochbegin(const QModelIndex &index) const;
    QVariant MengeSollKochende(const QModelIndex &index) const;
    QVariant SWSollLautern(const QModelIndex &index) const;
    QVariant SWSollKochbegin(const QModelIndex &index) const;
    QVariant SWSollKochende(const QModelIndex &index) const;
    QVariant SWSollAnstellen(const QModelIndex &index) const;
    QVariant KorrekturWasser(const QModelIndex &index) const;
    QVariant Verdampfungsziffer(const QModelIndex &index) const;
    QVariant WasserVerschneidung(const QModelIndex &index) const;
    QVariant RestalkalitaetFaktor(const QModelIndex &index) const;
    QVariant FaktorHauptgussEmpfehlung(const QModelIndex &index) const;
private:
    Brauhelfer* bh;
    bool updating;
    bool globalList;
    double *swWzMaischen;
    double *swWzKochen;
    double *swWzGaerung;
};

#endif // MODELSUD_H