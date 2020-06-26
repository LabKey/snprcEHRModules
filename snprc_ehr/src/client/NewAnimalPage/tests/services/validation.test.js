import moment from 'moment'
import { isBirthdateValid, validateCage } from '../../services/validation'

describe('isBirthdateValid tests', () => {
    test('Should not allow birthdate to be greater than acquisition date', () => {
        const birthdate = new Date('01/02/2020')
        const acqDate = new Date('01/01/2020')
        const result = isBirthdateValid(moment(birthdate), moment(acqDate))
        expect(result).toBe(false)
    })

    test('Should allow birthdate to be equal to acquisition date', () => {
        const birthdate = new Date('01/01/2020')
        const acqDate = new Date('01/01/2020')
        const result = isBirthdateValid(moment(birthdate), moment(acqDate))
        expect(result).toBe(true)
    })

    test('Should allow birthdate to be less than acquisition date', () => {
        const birthdate = new Date('01/01/2020')
        const acqDate = new Date('01/02/2020')
        const result = isBirthdateValid(moment(birthdate), moment(acqDate))
        expect(result).toBe(true)
    })
})

describe('validateCage tests', () => {
    const room = { value: '2.00', maxCages: 42 }
    test('Should allow cage to be less than room.maxCages', () => {
        const cage = 1
        const result = validateCage(room, cage)
        expect(result).toBeUndefined()
    })
    test('Should allow cage to equal room.maxCages', () => {
        const cage = 1
        const result = validateCage(room, cage)
        expect(result).toBeUndefined()
    })
    test('Should reject negative cage numbers', () => {
        const cage = -1
        const result = validateCage(room, cage)

        expect(result).toEqual(`Cage # must be between 1 and ${room.maxCages} in Location ${room.value}`)
    })
    test('should reject cage number greater than room.maxCages', () => {
        const cage = 43
        const result = validateCage(room, cage)
        expect(result).toEqual(`Cage # must be between 1 and ${room.maxCages} in Location ${room.value}`)
    })
    test('Should allow blank cage number', () => {
        const cage = ''
        const result = validateCage(room, cage)
        expect(result).toBeUndefined()
    })
})
