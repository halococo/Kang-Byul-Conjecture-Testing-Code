//
//  CalculCalculation.swift
//  Prime_mac
//
//  Created by Kang Byul on 2025/07/06.
//
import Foundation

class CalculCalculation {

    let testLimit: Int = 1_000_000_000  // Upper limit for prime checking
    let threadCount = ProcessInfo.processInfo.activeProcessorCount

    // MARK: - Prime number check
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

    // MARK: - The sum of the digits in base-7
    func sumOfBase7Digits(_ n: Int) -> Int {
        var num = n
        var sum = 0
        while num > 0 {
            sum += num % 7
            num /= 7
        }
        return sum
    }

    // MARK: - Check if the number is a product of primes
    func isProductOfPrimes(_ n: Int) -> Bool {
        if n < 2 { return false }
        var num = n
        for i in 2...Int(sqrt(Double(n))) {
            if isPrime(i) {
                while num % i == 0 {
                    num /= i
                }
            }
            if num == 1 { return true }
        }
        return isPrime(num)
    }

    // MARK: - Execute parallel processing
    func runKangByulConjecture(limit: Int, threads: Int) {
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "kangbyul.concurrent.queue", attributes: .concurrent)
        let step = limit / threads
        var violations = [(Int, Int)]()
        let lock = NSLock()

        print("🚀 Starting Kang Byul Conjecture Test up to \(limit) using \(threads) threads...")
        let startTime = Date()

        for i in 0..<threads {
            let start = i * step + (i == 0 ? 2 : 0)
            let end = (i == threads - 1) ? limit : (i + 1) * step - 1

            queue.async(group: group) {
                for p in start...end {
                    if self.isPrime(p) {
                        let s = self.sumOfBase7Digits(p)
                        if s != 1 && !self.isPrime(s) && !self.isProductOfPrimes(s) {
                            lock.lock()
                            violations.append((p, s))
                            print("Violation: Prime = \(p), Base-7 = \(String(p, radix: 7)), Digit Sum = \(s)")
                            lock.unlock()
                        }
                    }
                }
            }
        }

        group.notify(queue: .main) {
            let duration = Date().timeIntervalSince(startTime)
            print("🏁 Kang Byul Conjecture Test complete in \(String(format: "%.2f", duration)) seconds.")
            if violations.isEmpty {
                print("No violations found. The conjecture holds up to \(limit).")
            } else {
                print("\(violations.count) violation(s) found.")
            }
        }
    }

    // MARK: - Method to start execution
    func start() {
        runKangByulConjecture(limit: testLimit, threads: threadCount)
        RunLoop.main.run()  // Keep the main thread alive
    }
}
