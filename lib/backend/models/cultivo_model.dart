class Cultivo {
  int id;
  String nombre;
  Cultivo({required this.id, required this.nombre});
  factory Cultivo.fromJson(Map<String, dynamic> json) => Cultivo(
        id: json['id'],
        nombre: json['nombre'],
      );

  Map<String, dynamic> toJson() => {"id": id, "nombre": nombre};
}
