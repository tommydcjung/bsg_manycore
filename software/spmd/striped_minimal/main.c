#include "bsg_manycore.h"
#include "bsg_set_tile_x_y.h"
#include "bsg_tilegroup.h"

#define N bsg_group_size

int STRIPE A[N][N];


void remote_load_store_test(int id) {
    int other_id = (id) ? 0 : 3;

    for (int i = 0; i < N; i++) {
        A[i][other_id] = (other_id * 2) + i * 5;
        while (A[i][id] != (id * 2) + i * 5);
        //bsg_printf("%d: %d\n", id, i);
    }

    bsg_printf("Passed remote_load_store_test; id = %d\n", id);
}


int main()
{
    bsg_set_tile_x_y();


    if ((__bsg_x == 0) && (__bsg_y == 0)) {
        remote_load_store_test(__bsg_id);
    }
    if ((__bsg_x == bsg_tiles_X-1) && (__bsg_y == bsg_tiles_Y-1)) {
        //bsg_printf("x: %d, y: %d\n", bsg_x, bsg_y);
        //bsg_printf("----\n");
        remote_load_store_test(__bsg_id);

        //indexing_test();
        //char_ptr_arith_test();
        //short_ptr_arith_test();
        //struct_test();

        bsg_finish();
    }
    bsg_wait_while(1);
}
