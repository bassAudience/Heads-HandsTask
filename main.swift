//  Created by Ilia Kateshov on 24.02.2022.
//

import Foundation

struct Seed {
    var a: Int, b: Int, c: Int, d: Int
}

func xorShiftRand128(_ seed: inout Seed, _ size: Int) -> Int {
    let f = seed.a^(seed.a<<11) % size
    seed.a = seed.b
    seed.b = seed.c
    seed.c = seed.d
    seed.d = ((seed.d^(seed.d>>19)) ^ (f^(f>>8))) % size
    return seed.d
}

func PRNG(_ seed: Int) -> Int {     // has short period, but will be used to generate seeds
    return (seed * 73129 + 95121) % 1000
}

func swap(_ arr: inout Array<Int>, _ a: Int, _ b: Int) {
    let c = arr[a]
    arr[a] = arr[b]
    arr[b] = c
}

func reverse(_ arr: inout Array<Int>) {
    let N = arr.count
    for i in 0..<N/2 {
        let c = arr[i]
        arr[i] = arr[N-1-i]
        arr[N-1-i] = c
    }
}


func MedianOfThree(_ arr: inout Array<Int>, _ size: Int) -> Int {
    let pivot: Int = (size-1) / 2;                   // pivot splits array into two sub-arrays
    if (arr[0] > arr[size-1]) {
        swap(&arr, 0, size-1)
    }
    if (arr[pivot] > arr[size-1]) {
        swap(&arr, pivot, size-1)
    } else {
        if (arr[pivot] < arr[0]) {
            swap(&arr, pivot, 0)
        }
    }
    return pivot;
}

func QuickSort(_ arr: inout Array<Int>) {
    let size = arr.count
    if (size > 2) {
        var pivot: Int = MedianOfThree(&arr, size)
        var shift = 0
        
        for i in 1..<size-1 {
            if ((i < pivot) && (arr[i] > arr[pivot])) {
                shift -= 1
            }
            if ((i > pivot) && (arr[i] < arr[pivot])) {
                shift += 1
            }
        }
        if shift != 0 {
            swap(&arr, pivot, pivot+shift)
            pivot += shift;
        }
        var FFL = 0, FFR = size-1;           // FFL - "First element From Left" with value more than pivot
        for i in FFL+1..<pivot {            // FFR - "First element From Right" with value less than pivot
            if (arr[i] > arr[pivot]) {
                FFL = i
                for j in stride(from: FFR-1, to: pivot, by: -1) {
                    if (arr[j] < arr[pivot]) {
                        FFR = j
                        swap(&arr, FFR, FFL)
                        break
                    }
                }
            }
        }                                           // split array into two:
        var first = Array(arr[0..<pivot])           // slice with values less than pivot
        var second = Array(arr[pivot+1..<size])     // slice with values more than pivot
        QuickSort(&first)
        QuickSort(&second)
        arr = first + [arr[pivot]] + second
    }
    else {
        if (size == 2) {                        // sorting arrays size of two
            let a = arr[0], b = arr[1]
            arr[0] = min(a, b)
            arr[1] = max(a, b)
        }
    }
}

func generateArrays(_ N: Int, _ arrayLengthSeed: inout Seed, _ numberSeed: inout Seed) -> Array<Array<Int>> {
    var orderList: Array<Array<Int>> = []
    var matchLength: Set<Int> = []
    
    let ARRAYMAXSIZE = 1000
    let NUMBERMAXSIZE = 10000
    
    if ARRAYMAXSIZE < N {
        fatalError("Duplicate sizes cannot be avoided")
    }
    
    for _ in 0..<N {
        var arrSize = xorShiftRand128(&arrayLengthSeed, ARRAYMAXSIZE)
        while matchLength.contains(arrSize) {
            arrSize = xorShiftRand128(&arrayLengthSeed, ARRAYMAXSIZE)
        }
        matchLength.insert(arrSize)
        var arr = Array(repeating: 0, count: arrSize)
        for i in 0..<arrSize {
            arr[i] = xorShiftRand128(&numberSeed, NUMBERMAXSIZE)
        }
        orderList.append(arr)
    }
    
    return orderList
}

func main(_ N: Int) -> Array<Array<Int>> {
    var seed = Int(getpid())
    var randNums: [Int] = []  // will storage 8 random numbers for xorShift seeds
    for _ in 0..<8{
        seed = PRNG(seed)
        randNums.append(seed)
    }
    var arrayLengthSeed = Seed(a: randNums[0], b: randNums[1], c: randNums[2], d: randNums[3])
    var numberSeed = Seed(a: randNums[4], b: randNums[5], c: randNums[6], d: randNums[7])
    
    var orderList = generateArrays(N, &arrayLengthSeed, &numberSeed)
    
    for i in 0..<N {
        QuickSort(&orderList[i])
        if i%2 == 0 {
            reverse(&orderList[i])
        }
    }
    return orderList
}
