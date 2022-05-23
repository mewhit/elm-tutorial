import { Field, InputType, OmitType, PartialType } from '@nestjs/graphql';
import { Student } from './student.model';

@InputType()
export class StudentInput {
  @Field()
  firstName: string;

  @Field()
  lastName: string;

  @Field()
  nickName: string;

  @Field()
  email: string;
}
