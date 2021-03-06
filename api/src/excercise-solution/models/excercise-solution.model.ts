import { Directive, Field, Int, ObjectType } from '@nestjs/graphql';
import { Student } from 'src/student/models/student.model';
import { CompileResult } from '../../elm/test-result.model';
import { Excercise } from '../../excercise/models/excercise.model';

@ObjectType()
@Directive('@key(fields: "id")')
export class ExcerciseSolution {
  @Field({ nullable: true })
  id: string;

  @Field()
  code: string;

  @Field()
  excerciseId: string;

  @Field()
  userId: string;

  @Field(() => Student)
  student: Student;

  @Field(() => [CompileResult])
  results: CompileResult[];
}
