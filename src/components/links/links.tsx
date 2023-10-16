import React from "react";
import {Divider} from "../extras/divider.tsx";
import {WriteUpLink} from "./write-up-link.tsx";
import {Donate} from "./donate.tsx";
import {GithubLink} from "./github-link.tsx";

export const Links: React.FC = () => {
    return <div>
        <Divider/>
        <GithubLink/>
        <Divider/>
        <WriteUpLink/>
        <Divider/>
        <Donate/>
    </div>;
};
