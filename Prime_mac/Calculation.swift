//
//  CalculCalculation.swift
//  Prime_mac
//
//  Created by Kang Byul on 2025/07/06.
//
import Foundation

class CalculCalculation {

    let testLimit: Int = 10_000_000_000  // Upper limit for prime number verification
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

    // MARK: - 2. Base-7 Digit Sum Function
    func sumOfBase7Digits(_ n: Int) -> Int {
        var num = n
        var sum = 0
        while num > 0 {
            sum += num % 7
            num /= 7
        }
        return sum
    }

    // MARK: Checks if the input number is a semiprime (a product of two primes).
    func isSemiprime(_ n: Int) -> Bool {
        // The smallest semiprime is 4 (2*2).
        if n < 4 { return false }

        var num = n
        var primeFactorCount = 0

        // Count prime factors by dividing by 2.
        while num % 2 == 0 {
            primeFactorCount += 1
            // Optimization: exit immediately if factor count exceeds 2.
            if primeFactorCount > 2 { return false }
            num /= 2
        }

        // Count prime factors by dividing by odd numbers starting from 3.
        var i = 3
        while i * i <= num {
            while num % i == 0 {
                primeFactorCount += 1
                // Optimization
                if primeFactorCount > 2 { return false }
                num /= i
            }
            i += 2
        }
        
        // If num > 1 after the loop, the remaining number is a large prime factor itself.
        if num > 1 {
            primeFactorCount += 1
        }

        // Returns true only if the count of prime factors is exactly 2.
        return primeFactorCount == 2
    }

    // MARK: - 4. Parallel Execution Function
    func runSemiprimeConjectureTest(limit: Int, threads: Int) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "kangbyul.semiprime.queue", attributes: .concurrent)
        let step = limit / threads
        var violations = [(prime: Int, sum: Int)]()
        let lock = NSLock()

        print("🚀 Starting Semiprime Conjecture Test up to \(limit) using \(threads) threads...")
        let startTime = Date()

        for i in 0..<threads {
            // Adjust to start from 2.
            let start = i * step + (i == 0 ? 2 : 1)
            let end = (i == threads - 1) ? limit : start + step - 1

            queue.async(group: group) {
                for p in start...end {
                    if self.isPrime(p) {
                        let s7 = self.sumOfBase7Digits(p)
                        
                        // Condition to check for violations of the new conjecture.
                        // Finds cases where s7 is NOT 1, NOT a prime, and NOT a semiprime.
                        if s7 != 1 && !self.isPrime(s7) && !self.isSemiprime(s7) {
                            lock.lock()
                            violations.append((prime: p, sum: s7))
                            print("--------------------------------------------------")
                            print("❗️❗️❗️ VIOLATION FOUND ❗️❗️❗️")
                            print("Prime (p)      : \(p)")
                            print("Digit Sum (S₇) : \(s7)")
                            print(" -> S₇=\(s7) is NOT 1, NOT prime, and NOT a semiprime.")
                            print("--------------------------------------------------")
                            lock.unlock()
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            let duration = Date().timeIntervalSince(startTime)
            print("🏁 Test complete in \(String(format: "%.2f", duration)) seconds.")
            if violations.isEmpty {
                print("✅ No violations found. The Semiprime Conjecture holds up to \(limit).")
            } else {
                print("❌ Found \(violations.count) violation(s).")
            }
        }
    }

    // MARK: - 5. Execution Entry Point
    func start() {
        runSemiprimeConjectureTest(limit: testLimit, threads: threadCount)
        // Keep the main thread alive to allow async tasks to complete.
        RunLoop.main.run()
    }
}
