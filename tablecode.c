#include <math.h>
#include <stdio.h>
#include <sys/param.h>

static long reno(double p) { return lround(1.2 / pow(p, 0.5)); }

static long hstcp(double p) {
  const long cwnd = lround(0.12 / pow(p, 0.835));

  const long tcp_friend = reno(p);

  return MAX(tcp_friend, cwnd);
}

static long cubic(double C, double RTT, double p) {
  double w = pow(RTT, 0.75);
  w = w / pow(p, 0.75);
  w = w * pow(C * 3.7 / 1.2, 0.25);
  const long cwnd = lround(w);

  const long tcp_friend = reno(p);

  return MAX(tcp_friend, cwnd);
}

static void print_table(int nr, double RTT) {
  printf("\nTable %d (RTT=%gs)\n", nr, RTT);
  printf("%-7s %12s %12s %12s %12s %12s\n", "P", "TCP", "HSTCP", "C=0.04",
         "C=0.4", "C=4");

  for (long i = 2; i <= 8; i++) {
    const double p = pow(10, -i);
    printf("%.1e %12ld %12ld %12ld %12ld %12ld\n", p, reno(p), hstcp(p),
           cubic(0.04, RTT, p), cubic(0.4, RTT, p), cubic(4, RTT, p));
  }
}

int main() {
  print_table(1, 0.1);
  print_table(2, 0.01);

  return 0;
}
