import 'dart:convert';

class DataTypeUtil {
  static dynamic convertDataType(dynamic value, String toType) {
    switch (toType) {
      case 'int':
        return int.tryParse(value.toString()) ?? 0;
      case 'double':
        return double.tryParse(value.toString()) ?? 0.0;
      case 'bool':
        return value.toString().toLowerCase() == 'true';
      case 'String':
      case 'string':
        return value.toString();
      case 'datetime':
      case 'date':
        try {
          return DateTime.parse(value).toString();
        } catch (e) {
          return null;
        }
      case 'List':
      case 'list':
      case 'Map':
      case 'map':
        return json.decode(value.toString());
      // Add more cases for additional types as needed
      default:
        return value;
    }
  }
}
