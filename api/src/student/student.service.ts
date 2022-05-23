import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import * as Either from 'fp-ts/Either';
import { Model } from 'mongoose';
import { Err } from 'src/libs/Err';
import {
  CreateStudent,
  Student,
  StudentDocument,
} from './schemas/student.schema';

@Injectable()
export class StudentService {
  constructor(
    @InjectModel(Student.name) private studentRepo: Model<StudentDocument>,
  ) {}

  findOneById(id: string) {
    return this.studentRepo.findById(id).exec();
  }

  async create(student: CreateStudent): Promise<Either.Either<Err, Student>> {
    const alreadyExist = await this.studentRepo
      .find({ email: student.email })
      .exec();

    if (alreadyExist.length)
      return Either.left({ err: `${student.email} already use` });

    const createdStudent = new this.studentRepo(student);

    return Either.right(await createdStudent.save());
  }
}
