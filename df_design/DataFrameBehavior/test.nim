import arraymancer
import sugar

var df = toTensor([
    [1, 2, 3, 4, 5, 6],
    [1, 2, 3, 1, 2, 3],
    [1, 2, 1, 2, 1, 2],
]).transpose()
echo df

# echo df[_, 0] mod 2   # mod is missing
let mask = df[_, 0].map((x: int) => x mod 2 == 0)
echo mask

# indexing with boolean mask seems to be missing
# df[mask, 0] *= 100

# slicer seems to be immutable
# df[2..4, _] .*= 100
var subdf = df[2..4, _]
subdf[_, 0] .*= 100
echo subdf
echo df