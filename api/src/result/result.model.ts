interface Success {
    yourScore: {
        execTime: number
        lenght: number
    }
    communityScore: {
        execTime: number
        lenght: number
    }
    bestScore: {
        execTime: number
        lenght: number
    }
}

interface Failure {
    error: string
}

type Result = Success | Failure

