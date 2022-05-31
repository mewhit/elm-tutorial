import {
  createUnionType,
  Field,
  Int,
  ObjectType,
  ArrayElement,
  Float,
} from '@nestjs/graphql';
import { Either, left, right, sequenceArray } from 'fp-ts/Either';
import { Err } from '../libs/Err';

type TestEvent = 'runStart' | 'testCompleted' | 'runComplete';

type TestStatus = 'pass' | 'fail';

@ObjectType()
class RunStart {
  @Field()
  event: TestEvent;

  @Field(() => Int)
  testCount: number;

  @Field(() => Int)
  fuzzRuns: number;

  @Field(() => [String])
  paths: string[];

  @Field()
  initialSeed: string;
}

@ObjectType()
class TestCompleted {
  @Field()
  event: TestEvent;

  @Field()
  status: TestStatus;

  @Field(() => [String])
  labels: string[];

  @Field(() => [Failure])
  failures: Failure[];

  @Field(() => Float)
  duration: number;
}

@ObjectType()
class ReasonData {
  @Field()
  expected: string;

  @Field()
  actual: string;

  @Field()
  comparison: string;
}
@ObjectType()
class Reason {
  @Field()
  type: string;

  @Field(() => ReasonData)
  data: ReasonData;
}
@ObjectType()
class Failure {
  given: null;

  @Field()
  message: string;

  @Field(() => Reason)
  reason: Reason;
}

@ObjectType()
class RunComplete {
  @Field()
  event: TestEvent;

  @Field(() => Int)
  passed: number;

  @Field(() => Int)
  failed: number;

  @Field(() => Float)
  duration: number;
}

export const CompileResult = createUnionType({
  name: 'CompileResult',
  types: () => [RunComplete, RunStart, TestCompleted],
  resolveType(value) {
    if (value.event === 'runStart') return RunStart;
    if (value.event === 'testCompleted') return TestCompleted;

    return RunComplete;
  },
});

export type CompileResult = RunComplete | RunStart | TestCompleted;
