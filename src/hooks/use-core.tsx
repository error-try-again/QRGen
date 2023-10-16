import {useContext} from "react";
import {CoreContext, CoreContextType} from "../contexts/core-context.tsx";

export const useCore = (): CoreContextType => {
    const context = useContext(CoreContext);
    if (!context) {
        throw new Error('use-core.tsx must be used within a CoreProvider');
    }
    return context;
};
