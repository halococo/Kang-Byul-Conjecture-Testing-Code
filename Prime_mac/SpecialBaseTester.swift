import Foundation

class SpecialBaseTester {

    // --- Configuration ---
    let primeStart: Int = 1                 // Test primes from this number
    let primeLimit: Int = 1_000_000_000      // Test primes up to this number
    let specialBases: [Int] = [7, 13, 31, 61, 211, 421] // The specific bases to test
    // -------------------

    let threadCount = ProcessInfo.processInfo.activeProcessorCount

    // MARK: - 1. Primality Test Function
    func isPrime(_ n: Int) -> Bool {
        if n <= 1 { return false }
        if n <= 3 { return true }
        if n % 2 == 0 || n % 3 == 0 { return false }
        var i = 5
        while i * i <= n {
            if n % i == 0 || n % (i + 2) == 0 { return false }
            i += 6
        }
        return true
    }

    // MARK: - 2. Semiprime Test Function
    func isSemiprime(_ n: Int) -> Bool {
        if n < 4 { return false }
        var num = n
        var primeFactorCount = 0
        
        while num % 2 == 0 {
            primeFactorCount += 1
            if primeFactorCount > 2 { return false }
            num /= 2
        }
        var i = 3
        while i * i <= num {
            while num % i == 0 {
                primeFactorCount += 1
                if primeFactorCount > 2 { return false }
                num /= i
            }
            i += 2
        }
        if num > 1 {
            primeFactorCount += 1
        }
        return primeFactorCount == 2
    }

    // MARK: - 3. General Digit Sum Function
    func sumOfDigits(forNumber n: Int, inBase base: Int) -> Int {
        guard base >= 2 else { return -1 }
        var num = n
        var sum = 0
        while num > 0 {
            sum += num % base
            num /= base
        }
        return sum
    }

    // MARK: - 4. Main Test Execution for Special Bases
    func runSpecialBaseTest() {
        let effectiveStart = max(2, primeStart) // Primes must be >= 2
        
        print("🚀 Starting Special Base Conjecture Test")
        print(" -> Prime range: from \(effectiveStart) to \(primeLimit)")
        print(" -> Testing bases: \(specialBases)\n")

        let totalStartTime = Date()

        for base in specialBases {
            let baseStartTime = Date()
            print("--- Deep verification for base \(base)... ---")
            
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "conjecture.special.base\(base).queue", attributes: .concurrent)
            
            var violationFound = false
            let lock = NSLock()
            
            let range = primeLimit - effectiveStart + 1
            guard range > 0 else {
                print("   Invalid range. Skipping base \(base).\n")
                continue
            }
            
            // Distribute the work among threads
            let step = (range / threadCount) + 1

            for i in 0..<threadCount {
                group.enter()
                
                let threadStart = effectiveStart + (i * step)
                let threadEnd = min(threadStart + step - 1, primeLimit)

                guard threadStart <= threadEnd else {
                    group.leave()
                    continue
                }

                queue.async {
                    defer { group.leave() }
                    
                    for p in threadStart...threadEnd {
                        lock.lock()
                        let shouldStop = violationFound
                        lock.unlock()
                        if shouldStop { return }

                        if self.isPrime(p) {
                            let digitSum = self.sumOfDigits(forNumber: p, inBase: base)
                            
                            if digitSum != 1 && !self.isPrime(digitSum) && !self.isSemiprime(digitSum) {
                                lock.lock()
                                if !violationFound {
                                    violationFound = true
                                    print("--------------------------------------------------")
                                    print("❗️❗️❗️ VIOLATION FOUND IN BASE \(base) ❗️❗️❗️")
                                    print("Prime (p)      : \(p)")
                                    print("Digit Sum (S_\(base)) : \(digitSum)")
                                    print(" -> S_\(base)(\(p)) = \(digitSum) is NOT 1, NOT prime, and NOT a semiprime.")
                                    print("--------------------------------------------------")
                                }
                                lock.unlock()
                                return
                            }
                        }
                    }
                }
            }
            
            group.wait()
            
            let baseDuration = Date().timeIntervalSince(baseStartTime)
            lock.lock()
            let result = violationFound
            lock.unlock()
            
            if !result {
                print("✅ No violations found for base \(base) in range \(effectiveStart) to \(primeLimit).")
            }
            print("   (Verification for base \(base) took \(String(format: "%.2f", baseDuration))s)")
            print("-------------------------------------------\n")
        }
        
        let totalDuration = Date().timeIntervalSince(totalStartTime)
        print("🏁 Special Base Test complete in \(String(format: "%.2f", totalDuration)) seconds.")
    }
    
    // MARK: - 5. Execution Entry Point
    func start() {
        runSpecialBaseTest()
    }
}

