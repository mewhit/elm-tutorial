import { Either, left, right, sequenceArray } from 'fp-ts/Either'

type TestEvent = "runStart" | "testCompleted" | "runComplete"

type TestStatus = "pass" | "fail"

type RunStart = {
    event: TestEvent,
    testCount: number,
    fuzzRuns: number,
    globs: [],
    paths: string[],
    initialSeed: string
}

type TestCompleted = {
    event: TestEvent,
    status: TestStatus
    labels: string[],
    failures: { given: null, message: string, reason: { type: string, data: { expected: string, actual: string, comparison: string } } }[],
    duration: number
}

type RunComplete = {
    event: TestEvent,
    passed: number,
    failed: number,
    duration: number,
    autoFail: null
}

export type TestResult = RunStart | TestCompleted | RunComplete

export const fromBuffer = (buffer: Buffer): Either<string, readonly TestResult[]> => {
    return sequenceArray(buffer.toString().toString().split('\n').slice(0, -1).map(fromString))
}

export const fromString = (str: string): Either<string, TestResult> => {
    const unpur = JSON.parse(str)
    switch (unpur.event) {
        case "runStart":
            return right({
                event: unpur.event,
                testCount: +unpur.testCount,
                fuzzRuns: + unpur.fuzzRuns,
                globs: unpur.globs,
                paths: unpur.paths,
                initialSeed: unpur.initialSeed
            })
        case "testCompleted": return right({
            event: unpur.event,
            status: unpur.status,
            labels: unpur.labels,
            failures: unpur.failures,
            duration: +unpur.duration,
        })
        case "runComplete": return right({
            event: unpur.event,
            passed: +unpur.passed,
            failed: +unpur.failed,
            duration: +unpur.duration,
            autoFail: unpur.autoFail
        })
        default: left(`${unpur.event} does'nt exits into our system`)
    }
}


