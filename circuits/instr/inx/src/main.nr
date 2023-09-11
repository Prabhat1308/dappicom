use dep::helpers;


//PC = 8203
//X = 8201
//Y = 8202
//A = 8200
//SR = 8205
fn main(
    r: Field,
    op_sorted_step: [Field; 21],
    op_sorted_addr: [Field; 21],
    op_sorted_val: [Field; 21],
    op_sorted_op_rw: [Field; 21]
) -> pub Field {

    let mut index = 0;
    let mut padding = false;
    let mut end = false;
    for q in 0..20 {
        if (op_sorted_addr[index] == 1000000000) {
            padding = true;
        }
        if (index as u16 > 20) {
            padding = true;
            end = true;
        }
        if (!padding) {
            assert(op_sorted_addr[index] == 8203);
            assert(op_sorted_op_rw[index] == 0);
            assert(op_sorted_val[index] == 232);

            let mut sub_arr_addr: [Field; 2] = [0,0];
            let mut sub_arr_val: [Field; 2] = [0,0];
            let mut sub_arr_op_rw: [Field; 2] = [0,0];
            for i in index..2 {
                sub_arr_addr[i] = op_sorted_addr[i];
                sub_arr_val[i] = op_sorted_val[i];
                sub_arr_op_rw[i] = op_sorted_op_rw[i];
            }

            let address: Field = helpers::imm(
                sub_arr_addr,
                sub_arr_val,
                sub_arr_op_rw
            );

            // add the offset to the index
            index = index + address;

            // we perform a read of x
            assert(op_sorted_addr[index] == 8201);
            assert(op_sorted_op_rw[index] == 0);
            let value = op_sorted_val[index];
            index = index + 1;

            // we then perform a write of x + 1
            assert(op_sorted_addr[index] == 8201);
            assert(op_sorted_op_rw[index] == 1);
            let wadd = helpers::wrapping_add_u8(value, 1);
            assert(op_sorted_val[index] == wadd.value);
            index = index + 1;

            // we then set a new status into the status register 

            // first there is a read from the status register
            assert(op_sorted_addr[index] == 8205);
            assert(op_sorted_op_rw[index] == 0);
            let sr = op_sorted_val[index];
            index = index + 1;

            // next there is a write to the status register
            // we need to compute the zero and negative flag
            let zn = helpers::compute_zn_status(wadd.value);
            let srnew = helpers::update_status(sr, zn);
            assert(op_sorted_addr[index] == 8205);
            assert(op_sorted_op_rw[index] == 1);
            assert(op_sorted_val[index] == srnew);
            index = index + 1;
        } else {
            if (!end) {
                // this handles any necessary padding
                assert(op_sorted_addr[index] == 1000000000);
                assert(op_sorted_val[index] == 1000000000);
                assert(op_sorted_op_rw[index] == 1000000000);
            }
            index = index + 1;
        }
    }

    // Compute permutation and return it
    helpers::compute_permutation(
        r,
        op_sorted_step,
        op_sorted_addr,
        op_sorted_val,
        op_sorted_op_rw
    )
}