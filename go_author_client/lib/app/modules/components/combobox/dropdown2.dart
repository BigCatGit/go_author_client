import 'package:bot_toast/bot_toast.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

// options里的key和value都必须唯一
class Dropdown2 extends StatelessWidget {
  List<String> selectedKeys = [];
  List<dynamic> selectedValues = [];
  List<String> keys = [];
  List<Map<String, dynamic>> items = [];
  final Map<String, dynamic> _data = {};

  Widget? hint;
  bool isExpanded;
  bool isDense;
  bool autofocus;
  bool selectable;
  bool multiSelectable;
  double? dropdownMaxHeight;
  // 默认文本左对齐
  bool textAlignmentStart;
  AlignmentGeometry alignment;
  TextStyle? style;
  ButtonStyleData? buttonStyleData;
  IconStyleData iconStyleData;
  // 该样式会取消文本左对齐
  DropdownStyleData? dropdownStyleData;
  MenuItemStyleData menuItemStyleData;
  Widget? underline;
  Function(List<String> selectedKeys, List<dynamic> selectedValues)? onChanged;
  OnMenuStateChangeFn? onMenuStateChange;
  FormFieldValidator<String>? validator;

  Dropdown2({
    super.key,
    required this.selectedValues,
    required this.items,
    this.hint,
    this.isExpanded = false,
    this.isDense = false,
    this.autofocus = false,
    this.alignment = AlignmentDirectional.centerStart,
    this.style,
    this.underline,
    this.onChanged,
    this.onMenuStateChange,
    this.validator,
    this.selectable = false,
    this.textAlignmentStart = false,
    this.multiSelectable = false,
    this.buttonStyleData,
    this.iconStyleData = const IconStyleData(),
    this.dropdownStyleData,
    this.dropdownMaxHeight,
    this.menuItemStyleData = const MenuItemStyleData(),
  }) {
    // 将列表转成map
    for (var item in this.items) {
      this._data[item["name"]] = item["value"];
    }

    // 选中后的值是value, 需要转换为key
    for (var value in selectedValues) {
      var key = this.valueToKey(value);
      if (key != null) {
        this.selectedKeys.add(key);
      }
    }

    // 将key值转换为数组
    for (var item in this.items) {
      this.keys.add(item["name"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      DropdownButtonBuilder? selectBuilder;
      if (!this.selectable || !this.multiSelectable) {
        selectBuilder = null;
      } else {
        // 多选时初始化选择构建器
        selectBuilder = (context) {
          return [
            Text(
              selectedKeys.join(', '),
              style: TextStyle(overflow: TextOverflow.ellipsis),
              maxLines: 1,
            ),
          ];
        };
      }
      String? defaultValue;
      if (this.selectable && this.multiSelectable) {
        // 这里特别注意，只有有默认选中项的时候，才将默认值设置为第一项，否则无法正常显示
        if (this.selectedValues.isNotEmpty) {
          defaultValue = keys.first;
        } else {
          // 而是新的时候，没有默认选中项，我们要提示hint, 所以必须设置为null
          defaultValue = null;
        }
      } else {
        if (this.selectedKeys.isNotEmpty) {
          defaultValue = selectedKeys.first;
        }
      }
      dropdownStyleData ??= DropdownStyleData(
        maxHeight: dropdownMaxHeight ?? 480,
        // 设置与父控件宽度相同, 这个属性设置过后就可以让文本左对齐
        width: textAlignmentStart ? constraints.maxWidth : null,
      );
      return DropdownButtonHideUnderline(
        child: DropdownButtonFormField2<String>(
          isDense: isDense,
          autofocus: autofocus,
          hint: hint,
          isExpanded: isExpanded,
          // 这里的初始值非常关闭，与当前选中的值没有关系，直接设置为数组第一个即可
          value: defaultValue,
          alignment: alignment,
          style: style,
          validator: validator,
          onMenuStateChange: onMenuStateChange,
          // 弹出设置下拉列表样式
          // dropdownStyleData: DropdownStyleData(
          //   width: 400, // 指定宽度可以让内容左对齐
          // ),
          buttonStyleData: buttonStyleData,
          iconStyleData: iconStyleData,
          dropdownStyleData: dropdownStyleData!,
          menuItemStyleData: menuItemStyleData,
          // TODO 搜索功能看官方文档
          items: this.keys.map((name) {
            if (!this.selectable || !this.multiSelectable) {
              return DropdownMenuItem<String>(
                value: name,
                child: Text(name),
              );
            }
            return DropdownMenuItem<String>(
              value: name,
              //disable default onTap to avoid closing menu when selecting an item
              enabled: false,
              child: StatefulBuilder(
                builder: (context, menuSetState) {
                  final isSelected = selectedKeys.contains(name);
                  return InkWell(
                    onTap: () {
                      if (isSelected) {
                        if (!this.selectable || !this.multiSelectable) {
                          this.selectedKeys.clear();
                        }
                        selectedKeys.remove(name);
                        selectedValues.remove(_data[name]);
                      } else {
                        selectedKeys.add(name);
                        selectedValues.add(_data[name]);
                      }
                      //This rebuilds the StatefulWidget to update the button's text
                      // setState(() {});
                      //This rebuilds the dropdownMenu Widget to update the check mark
                      menuSetState(() {});
                      if (selectedKeys.length != selectedValues.length) {
                        BotToast.showText(text: "下拉列表缓存数据同步错误");
                        return;
                      }
                      if (onChanged != null) {
                        onChanged!(selectedKeys, selectedValues);
                      }
                    },
                    child: Container(
                      height: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 0.0),
                      child: Row(
                        children: [
                          if (isSelected) Icon(Icons.check_box_outlined) else Icon(Icons.check_box_outline_blank),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(name),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
          onChanged: _onChange,
          // 选择完成后显示的控件, 这里可以实现动态删除的效果
          selectedItemBuilder: selectBuilder,
        ),
      );
    });
  }

  _onChange(name) {
    if (!this.selectable || !this.multiSelectable) {
      this.selectedKeys.clear();
      this.selectedValues.clear();
    }
    if (name != null) {
      this.selectedKeys.add(name);
      this.selectedValues.add(_data[name]);
    }
    if (onChanged != null) {
      onChanged!(selectedKeys, selectedValues);
    }
  }

  String? valueToKey(dynamic value) {
    if (value == null) {
      return null;
    }
    for (var entry in this._data.entries) {
      if (entry.value == value) {
        return entry.key;
      }
    }
    return null;
  }

  dynamic keyToValue(String key) {
    return this._data[key];
  }
}
