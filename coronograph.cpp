#include<stdio.h>
#include<list>

using namespace std;

class graph {
	private:
		int V, *parent, explored = 0, cycleFirst = -1, cycleLast;
		list<int> *N;

	public:
		graph(int v) {
			V = v;
			N = new list<int>[V];
			parent = new int[V];
			for(int i = 0; i < V; parent[i++] = -1);
		}

		~graph() {
			for(int i = 0; i < V; N[i++].clear());
			delete[] N;
			delete[] parent;
		}

		void setEdge(int x, int y) {
			N[x].push_front(y);
			N[y].push_front(x);
		}

		void removeEdge(int x, int y) {
			N[x].remove(y);
			N[y].remove(x);
		}

		bool isConnected() {
			parent[0] = 0;
			dfs(0);
			return explored == V;
		}

		void dfs(int current) {
			int next;
			list<int>::iterator it, end = N[current].end();
			explored++;
			for(it = N[current].begin(); it != end; ++it) {
				next = *it;
				if(parent[next] < 0) {
					parent[next] = current;
					dfs(next);
				}
				else if(cycleFirst < 0 && parent[current] != next) {
					parent[next] = current;
					cycleLast = current;
					cycleFirst = next;
				}
			}
		}


		list<int> extractCycle(int &size) {
			list<int> cycle;
			size = 1;
			for(int v = cycleLast; v != cycleFirst; v = parent[v]) {
				removeEdge(v, parent[v]); 
				cycle.push_back(v);
				size++;
			}
			removeEdge(cycleFirst, cycleLast);
			cycle.push_back(cycleFirst);
			return cycle;
		}

		int getTreeSize(int current_node, int parent_node) {
			int treeSize = 1, next;
			while(!N[current_node].empty()){
				next = N[current_node].front();
				if(next != parent_node) treeSize += getTreeSize(next, current_node);
				N[current_node].pop_front();
			}
			return treeSize;
		}
};

int main(int argc, char **argv) {
	FILE *fp;
	int T, V, E, x, y, cycleSize, i = 0, j;
	list<int> cycle, treeSize;
	graph *myGraph;
	fp = fopen(argv[1], "r");
	fscanf(fp,  "%d", &T);
	while(i++ < T) {
		fscanf(fp,  "%d %d", &V, &E);
		if(E == V) {
			myGraph = new graph(V);
			for(j = 0; j < E; j++) {
				fscanf(fp,  "%d %d", &x, &y);
				myGraph->setEdge(x-1, y-1);
			}
			if(myGraph->isConnected()) {
				cycle = myGraph->extractCycle(cycleSize);
				printf("CORONA %d\n", cycleSize);
				for(j = 0; j < cycleSize; j++) {
					V = cycle.front();
					treeSize.push_front(myGraph->getTreeSize(V, V));
					cycle.pop_front();
				}
				treeSize.sort();
				for(j = 0; j < cycleSize - 1; j++) {
					printf("%d ", treeSize.front());
					treeSize.pop_front();
				}
				printf("%d\n", treeSize.front());
				treeSize.pop_front();
			}
			else printf("NO CORONA\n");
			delete myGraph;
		}
		else {
			printf("NO CORONA\n");
			for(j = 0; j < E; j++) {
				fscanf(fp,  "%d %d", &x, &y);
			}
		}
	}
	fclose(fp);
}





