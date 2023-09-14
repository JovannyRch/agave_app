class ChartData {
  ChartData(this.distancia, this.semivariograma);
  final double distancia;
  final double semivariograma;
  @override
  String toString() {
    // TODO: implement toString
    return "$distancia => $semivariograma";
  }
}
