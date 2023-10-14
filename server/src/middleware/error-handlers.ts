import express from "express";

export function handleArchiveError(error: Error, response: express.Response) {
    console.error(error);
    if (error.message.includes('Trouble appending files to archive.')) {
        response.status(500).json({message: error.message});
    } else if (error.message.includes('Trouble setting headers.')) {
        response.status(500).json({message: error.message});
    } else {
        response.status(500).json({message: 'An error occurred during archiving.'});
    }
}
