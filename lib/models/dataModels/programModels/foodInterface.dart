
mixin FoodInterface<T> {
  T fromMap(Map<String, dynamic> map);
  toMap();

  sortChildren();
}