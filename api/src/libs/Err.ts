import { Field, ObjectType } from '@nestjs/graphql';

@ObjectType()
export class Err {
  @Field()
  err: string;
}
