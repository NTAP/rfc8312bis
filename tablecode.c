#include <math.h>
#include <stdio.h>

static long wnd(double C, double RTT, double p) {
  double w = pow(RTT, 0.75);
  w /= pow(p, 0.75);
  w *= pow(C * 3.7 / 1.2, 0.25);

  const double tcp = 1.2 * pow(1.0 / p, 0.5);

  if (tcp > w)
    return tcp + 0.5;

  return w + 0.5;
}

int main() {
  puts("Table 1");
  for (long i = 2; i <= 8; i++) {
    const double p = pow(10, -i);
    printf("| 10^-%01lu | %10lu | %10lu | %10lu |\n", i, wnd(0.04, 0.1, p),
           wnd(0.4, 0.1, p), wnd(4, 0.1, p));
  }

  puts("\nTable 2");
  for (long i = 2; i <= 8; i++) {
    const double p = pow(10, -i);
    printf("| 10^-%01lu | %10lu | %10lu | %10lu |\n", i, wnd(0.04, 0.01, p),
           wnd(0.4, 0.01, p), wnd(4, 0.01, p));
  }

  return 0;
}
