import { Prop } from '@nestjs/mongoose';
import { Either, left, right, sequenceArray } from 'fp-ts/Either';

type TestEvent = 'runStart' | 'testCompleted' | 'runComplete';

type TestStatus = 'pass' | 'fail';

class RunStart {
  @Prop()
  event: TestEvent;

  @Prop()
  testCount: number;

  @Prop()
  fuzzRuns: number;

  @Prop(() => [String])
  paths: string[];

  @Prop()
  initialSeed: string;
}

class TestCompleted {
  @Prop()
  event: TestEvent;

  @Prop()
  status: TestStatus;

  @Prop(() => [String])
  labels: string[];

  @Prop(() => [Failure])
  failures: Failure[];

  @Prop()
  duration: number;
}

class ReasonData {
  @Prop()
  expected: string;

  @Prop()
  actual: string;

  @Prop()
  comparison: string;
}
class Reason {
  @Prop()
  type: string;

  @Prop(() => ReasonData)
  data: ReasonData;
}

class Failure {
  given: null;

  @Prop()
  message: string;

  @Prop(() => Reason)
  reason: Reason;
}

class RunComplete {
  @Prop()
  event: TestEvent;

  @Prop()
  passed: number;

  @Prop()
  failed: number;

  @Prop()
  duration: number;
}

export type CompileResult = RunComplete | RunStart | TestCompleted;

export const fromBuffer = (
  buffer: Buffer,
): Either<string, readonly CompileResult[]> => {
  return sequenceArray(
    buffer.toString().toString().split('\n').slice(0, -1).map(fromString),
  );
};

export const fromString = (str: string): Either<string, CompileResult> => {
  const unpur = JSON.parse(str);
  switch (unpur.event) {
    case 'runStart':
      return right({
        event: unpur.event,
        testCount: +unpur.testCount,
        fuzzRuns: +unpur.fuzzRuns,
        globs: unpur.globs,
        paths: unpur.paths,
        initialSeed: unpur.initialSeed,
      });
    case 'testCompleted':
      return right({
        event: unpur.event,
        status: unpur.status,
        labels: unpur.labels,
        failures: unpur.failures,
        duration: +unpur.duration,
      });
    case 'runComplete':
      return right({
        event: unpur.event,
        passed: +unpur.passed,
        failed: +unpur.failed,
        duration: +unpur.duration,
        autoFail: unpur.autoFail,
      });
    default:
      left(`${unpur.event} does'nt exits into our system`);
  }
};
