#include<stdio.h>
#include<cmath>

using namespace std;

class powers2 {
	private:
		int N, K, powerSize, *powers, numPower = 0;
	
	public:
		void find_binary() {
			int i = 0, N_temp = N, rem;
			while(i < powerSize) {
				rem = N_temp % 2;
				numPower += rem;
				powers[i++] = rem;
				N_temp /= 2;
			}
		}

		powers2(int n, int k) {
			N = n;
			K = k;
			powerSize = floor(log2(N)) + 1;
			powers = new int[powerSize];
			find_binary();
		}

		~powers2() {
			delete powers;
		}

		bool expand(int n) {
			int p = int(pow(2, n));
			if (numPower + p - 1 > K) {
				powers[n] -= 1;
				powers[n-1] += 2;
				numPower++;
				return 0;
			}
			else {
				powers[n] -= 1;
				powers[0] += p;
				numPower += p - 1;
				return 1;
			}
		}

		int find_minExpand(int start) {
			for(int i = start; i < powerSize; i++) {
				if(powers[i]) return i;
			}
			return -1;
		}

		bool minimize() {
			if(K < numPower) return 0;
			int minExpand = find_minExpand(1);
			while(numPower < K) {
				if(expand(minExpand)) minExpand = find_minExpand(minExpand);
			       	else minExpand--;	
			}
			return 1;
		}

		void present() {
			for(int i =0, count = 0; count < K; i++) {
				printf("%d", powers[i]);
				count += powers[i];
				if(count < K) printf(",");
			}
	
		}
};

int main(int argc, char **argv) {
	FILE *fp;
	int T, n, k, i = 0;
	powers2 * myPowers;
	fp = fopen(argv[1], "r");
	fscanf(fp, "%d", &T);
	while(i++ < T) {
		fscanf(fp, "%d %d", &n, &k);
		printf("[");
		if(n > k) {
			myPowers = new powers2(n, k);
			if(myPowers->minimize()) {
				myPowers->present();
			}
			delete myPowers;
		}
		else if(n == k) printf("%d", n);
		printf("]\n");
	}
	fclose(fp);
}
