//
//  SpecialBaseTester.swift
//  Prime_mac
//
//  Created by Byul Kang on 2025/07/07.
//

import Foundation

class GeneralConjectureTester {

    // --- Configuration ---
    let primeLimit: Int = 1_000_000_000         // Test primes up to this number
    let startBase: Int = 2000                 // k: Starting base for the test
    let endBase: Int = 5000                   // l: Ending base for the test
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

    // MARK: - 4. Main Test Execution
    func runGeneralTest() {
        print("🚀 Starting General Conjecture Test")
        print(" -> Prime limit: \(primeLimit)")
        print(" -> Base range: from \(startBase) to \(endBase)\n")

        let totalStartTime = Date()
        var totalViolationsFound = 0

        // Loop through each base from k to l
        for base in startBase...endBase {
            let baseStartTime = Date()
            print("--- Testing for base \(base)... ---")
            
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "conjecture.base\(base).queue", attributes: .concurrent)
            
            // Shared variable to store the first violation found for the current base
            var firstViolation: (prime: Int, sum: Int)? = nil
            let lock = NSLock()
            
            let step = primeLimit / threadCount

            for i in 0..<threadCount {
                group.enter()
                let start = i * step + (i == 0 ? 2 : 1)
                let end = (i == threadCount - 1) ? primeLimit : start + step - 1

                queue.async {
                    defer { group.leave() }
                    
                    for p in start...end {
                        // If another thread has already found a violation for this base, stop.
                        lock.lock()
                        let violationFound = (firstViolation != nil)
                        lock.unlock()
                        if violationFound {
                            return // Exit this thread's work for the current base
                        }

                        if self.isPrime(p) {
                            let digitSum = self.sumOfDigits(forNumber: p, inBase: base)
                            
                            // Check for violations of the conjecture
                            if digitSum != 1 && !self.isPrime(digitSum) && !self.isSemiprime(digitSum) {
                                lock.lock()
                                // Double-check to ensure this thread is the first to report
                                if firstViolation == nil {
                                    firstViolation = (prime: p, sum: digitSum)
                                }
                                lock.unlock()
                                return // Exit after finding the first violation
                            }
                        }
                    }
                }
            }
            
            group.wait() // Wait for all threads for the current base to complete
            
            let baseDuration = Date().timeIntervalSince(baseStartTime)
            if let violation = firstViolation {
                print("❌ Violation found in base \(base): S_\(base)(\(violation.prime)) = \(violation.sum)")
                totalViolationsFound += 1
            } else {
                print("✅ No violations found in base \(base).")
            }
            print("   (Took \(String(format: "%.2f", baseDuration))s)")
            print("--------------------------------\n")
        }
        
        let totalDuration = Date().timeIntervalSince(totalStartTime)
        print("🏁 General Test complete in \(String(format: "%.2f", totalDuration)) seconds.")
        print("Total bases with violations: \(totalViolationsFound)")
    }
    
    // MARK: - 5. Execution Entry Point
    func start() {
        runGeneralTest()
    }
}

// To run the test:
// let tester = GeneralConjectureTester()
// tester.start()

