import { Injectable } from '@nestjs/common';
import { execSync } from 'child_process';
import { fromBuffer, TestResult } from './test-result.model';
import * as Either from 'fp-ts/Either'
type Path = string



@Injectable()
export class ElmService {

    test(excercisePath: Path): Either.Either<string, readonly TestResult[]> {
        try {
            return fromBuffer(execSync(`cd ${excercisePath} && elm-test --report=json`))
        } catch (err) {
            const error = err.stderr.toString();
            if (error !== "") {
                return Either.left(error);
            }

            console.log(err);
            const output = fromBuffer(err.stdout);

            return output;
        }
    }

    make() {
        // // try {
        // //   execSync(`cd ${excercisePath} && elm make ./src/Main.elm`)
        // // } catch (err) {
        // //   fs.writeFileSync(`${excercisePath}/index.html`, `<p style="white-space: pre-wrap">${err.stderr.toString()}</p>`)
        // // }<

    }


}
