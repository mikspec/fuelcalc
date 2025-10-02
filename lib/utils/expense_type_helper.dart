import '../l10n/app_localizations.dart';

class ExpenseTypeHelper {
  /// Zwraca zlokalizowaną nazwę typu wydatku
  static String getLocalizedTypeName(AppLocalizations l10n, int typeId) {
    switch (typeId) {
      case 0:
        return l10n.expenseTypeOther;
      case 1:
        return l10n.expenseTypeBattery;
      case 2:
        return l10n.expenseTypeRepair;
      case 3:
        return l10n.expenseTypeTowing;
      case 4:
        return l10n.expenseTypeInsurance;
      case 5:
        return l10n.expenseTypeInspection;
      default:
        return l10n.expenseTypeUnknown;
    }
  }

  /// Zwraca mapę typów wydatków z zlokalizowanymi nazwami
  static Map<int, String> getLocalizedExpenseTypes(AppLocalizations l10n) {
    return {
      0: l10n.expenseTypeOther,
      1: l10n.expenseTypeBattery,
      2: l10n.expenseTypeRepair,
      3: l10n.expenseTypeTowing,
      4: l10n.expenseTypeInsurance,
      5: l10n.expenseTypeInspection,
    };
  }
}