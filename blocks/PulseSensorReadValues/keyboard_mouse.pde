
void mousePressed() {
  scaleBar.press(mouseX, mouseY);
}

void mouseReleased() {
  scaleBar.release();
}

void keyPressed() {

  switch(key) {
  case 's':
  case 'S':
    print_serial = !print_serial;
    break;
  case 'v':
  case 'V':
    print_verbose = !print_verbose;
    break;
  default:
    break;
  }
}

