import {
  Args,
  Mutation,
  Query,
  Resolver,
  ResolveReference,
  createUnionType,
} from '@nestjs/graphql';
import * as Either from 'fp-ts/Either';
import { Err } from 'src/libs/Err';
import { StudentInput } from './models/student-input';
import { Student as StudentModel } from './models/student.model';
import { Student } from './schemas/student.schema';
import { StudentService } from './student.service';

export const Result = createUnionType({
  name: 'Result',
  types: () => [Err, StudentModel] as const,
  resolveType(value) {
    if (value.err) {
      return Err;
    }

    return StudentModel;
  },
});

@Resolver(() => StudentModel)
export class StudentResolver {
  constructor(private readonly studentService: StudentService) {}
  @Query(() => StudentModel)
  async author(@Args('id') id: string) {
    return this.studentService.findOneById(id);
  }

  @ResolveReference()
  resolveReference({ id }: { __typename: string; id: string }) {
    return this.studentService.findOneById(id);
  }

  @Mutation(() => Result, { name: 'studentRegister' })
  async register(@Args('data') student: StudentInput) {
    const studentResult = await this.studentService.create(student);

    return Either.fold<Err, Student, Err | Student>(
      (e) => e,
      (r) => r,
    )(studentResult);
  }
}
