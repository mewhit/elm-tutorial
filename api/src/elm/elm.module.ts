import { Module } from '@nestjs/common';
import { ElmService } from './elm.service';

@Module({
    providers: [ElmService],
    exports: [ElmService]
})
export class ElmModule { }
