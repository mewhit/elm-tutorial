import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Student, StudentSchema } from './schemas/student.schema';
import { StudentResolver } from './student.resolver';
import { StudentService } from './student.service';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Student.name, schema: StudentSchema }]),
  ],
  providers: [StudentResolver, StudentService],
})
export class StudentModule {}
