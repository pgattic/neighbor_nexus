
class MapIcon {
  static String getGraphic(String input) {
    switch (input) {
      case 'Party':
        return "assets/images/confetti-smol.png";
      case 'Sale':
        return "assets/images/sale-tag-smol.png";
      case 'Help':
        return "assets/images/help-smol.png";
      case "Ride-Share":
        return "assets/images/car-smol.png";
      default:
        return "assets/images/pin-smol.png";
    }
  }
}

